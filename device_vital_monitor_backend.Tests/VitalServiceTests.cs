using device_vital_monitor_backend.Data;
using device_vital_monitor_backend.DTOs;
using device_vital_monitor_backend.Models;
using device_vital_monitor_backend.Repositories;
using device_vital_monitor_backend.Services;
using Microsoft.EntityFrameworkCore;

namespace device_vital_monitor_backend.Tests;

public class VitalServiceTests : IDisposable
{
    private readonly VitalContext _context;
    private readonly VitalService _sut;

    public VitalServiceTests()
    {
        var options = new DbContextOptionsBuilder<VitalContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;
        _context = new VitalContext(options);
        _context.Database.EnsureCreated();
        var repo = new DeviceVitalRepository(_context);
        _sut = new VitalService(repo);
    }

    public void Dispose() => _context.Dispose();

    private static DeviceVital CreateValidVital(DateTime? timestamp = null, string deviceId = "device-1") => new()
    {
        DeviceId = deviceId,
        Timestamp = timestamp ?? DateTime.UtcNow.AddMinutes(-1),
        ThermalValue = 1,
        BatteryLevel = 50.0,
        MemoryUsage = 60.0
    };

    [Fact]
    public async Task LogVitalAsync_Saves_Valid_Vital()
    {
        // Arrange
        var vital = CreateValidVital();

        // Act
        var result = await _sut.LogVitalAsync(vital);

        // Assert
        Assert.NotNull(result);
        Assert.True(result.Id > 0);
        Assert.Equal(vital.DeviceId, result.DeviceId);
        Assert.Equal(vital.ThermalValue, result.ThermalValue);
        Assert.Equal(vital.BatteryLevel, result.BatteryLevel);
        Assert.Equal(vital.MemoryUsage, result.MemoryUsage);
        Assert.Equal(1, await _context.DeviceVitals.CountAsync());
    }

    [Fact]
    public async Task LogVitalAsync_Returns_Saved_Vital_With_Id()
    {
        // Arrange
        var vital = CreateValidVital();

        // Act
        var result = await _sut.LogVitalAsync(vital);

        // Assert
        Assert.True(result.Id > 0);
        var saved = await _context.DeviceVitals.FirstAsync();
        Assert.Equal(result.Id, saved.Id);
    }

    [Fact]
    public async Task GetHistoryAsync_Returns_Paged_Results()
    {
        // Arrange - Create 25 vitals
        for (int i = 0; i < 25; i++)
        {
            var vital = CreateValidVital(DateTime.UtcNow.AddMinutes(-i));
            await _sut.LogVitalAsync(vital);
        }

        // Act
        var result = await _sut.GetHistoryAsync(page: 1, pageSize: 10);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(10, result.Data.Count());
        Assert.Equal(1, result.Page);
        Assert.Equal(10, result.PageSize);
        Assert.Equal(25, result.TotalCount);
        Assert.Equal(3, result.TotalPages);
        Assert.True(result.HasNextPage);
        Assert.False(result.HasPreviousPage);
    }

    [Fact]
    public async Task GetHistoryAsync_Returns_Second_Page()
    {
        // Arrange - Create 25 vitals
        for (int i = 0; i < 25; i++)
        {
            var vital = CreateValidVital(DateTime.UtcNow.AddMinutes(-i));
            await _sut.LogVitalAsync(vital);
        }

        // Act
        var result = await _sut.GetHistoryAsync(page: 2, pageSize: 10);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(10, result.Data.Count());
        Assert.Equal(2, result.Page);
        Assert.True(result.HasNextPage);
        Assert.True(result.HasPreviousPage);
    }

    [Fact]
    public async Task GetHistoryAsync_Returns_Ordered_By_Timestamp_Descending()
    {
        // Arrange - Create vitals with different timestamps
        var baseTime = DateTime.UtcNow;
        for (int i = 0; i < 5; i++)
        {
            var vital = CreateValidVital(baseTime.AddMinutes(-i));
            await _sut.LogVitalAsync(vital);
        }

        // Act
        var result = await _sut.GetHistoryAsync(page: 1, pageSize: 5);

        // Assert
        var items = result.Data.ToList();
        Assert.Equal(5, items.Count);
        // Should be ordered newest first
        for (int i = 0; i < items.Count - 1; i++)
        {
            Assert.True(items[i].Timestamp >= items[i + 1].Timestamp);
        }
    }

    [Fact]
    public async Task GetAnalyticsAsync_RollingAverage_Uses_Last_100_Logs_Only()
    {
        // Arrange - Insert 50 logs with thermal=2, then 100 logs with thermal=1 (most recent)
        var baseTime = DateTime.UtcNow.AddHours(-2);
        
        for (int i = 0; i < 50; i++)
        {
            var vital = new DeviceVital
            {
                DeviceId = "d1",
                Timestamp = baseTime.AddSeconds(i),
                ThermalValue = 2,
                BatteryLevel = 50,
                MemoryUsage = 50
            };
            await _sut.LogVitalAsync(vital);
        }

        for (int i = 0; i < 100; i++)
        {
            var vital = new DeviceVital
            {
                DeviceId = "d1",
                Timestamp = baseTime.AddMinutes(1).AddSeconds(i),
                ThermalValue = 1,
                BatteryLevel = 50,
                MemoryUsage = 50
            };
            await _sut.LogVitalAsync(vital);
        }

        // Act
        var analytics = await _sut.GetAnalyticsAsync();

        // Assert
        // Last 100 all have thermal=1, so rolling average thermal must be 1.0
        Assert.Equal(150, analytics.TotalLogs);
        Assert.Equal(100, analytics.RollingWindowLogs);
        Assert.Equal(1.0, analytics.AverageThermal);
        Assert.Equal(50.0, analytics.AverageBattery);
        Assert.Equal(50.0, analytics.AverageMemory);
        Assert.Equal(1, analytics.MinThermal);
        Assert.Equal(1, analytics.MaxThermal);
        Assert.Equal(50.0, analytics.MinBattery);
        Assert.Equal(50.0, analytics.MaxBattery);
        Assert.Equal(50.0, analytics.MinMemory);
        Assert.Equal(50.0, analytics.MaxMemory);
        Assert.Equal("stable", analytics.TrendThermal);
        Assert.Equal("stable", analytics.TrendBattery);
        Assert.Equal("stable", analytics.TrendMemory);
    }

    [Fact]
    public async Task GetAnalyticsAsync_When_Fewer_Than_100_Logs_Returns_All()
    {
        // Arrange
        var vital1 = CreateValidVital();
        vital1.ThermalValue = 1;
        vital1.BatteryLevel = 50;
        vital1.MemoryUsage = 60;
        await _sut.LogVitalAsync(vital1);

        var vital2 = CreateValidVital();
        vital2.ThermalValue = 3;
        vital2.BatteryLevel = 80;
        vital2.MemoryUsage = 40;
        await _sut.LogVitalAsync(vital2);

        // Act
        var analytics = await _sut.GetAnalyticsAsync();

        // Assert
        Assert.Equal(2, analytics.TotalLogs);
        Assert.Equal(2, analytics.RollingWindowLogs);
        Assert.Equal(2.0, analytics.AverageThermal); // (1+3)/2
        Assert.Equal(65.0, analytics.AverageBattery); // (50+80)/2
        Assert.Equal(50.0, analytics.AverageMemory); // (60+40)/2
        Assert.Equal(1, analytics.MinThermal);
        Assert.Equal(3, analytics.MaxThermal);
        Assert.Equal(50.0, analytics.MinBattery);
        Assert.Equal(80.0, analytics.MaxBattery);
        Assert.Equal(40.0, analytics.MinMemory);
        Assert.Equal(60.0, analytics.MaxMemory);
        // Order newest first: vital2 then vital1. Recent half=(3,80,40), older=(1,50,60) => thermal increasing, battery increasing, memory decreasing
        Assert.Equal("increasing", analytics.TrendThermal);
        Assert.Equal("increasing", analytics.TrendBattery);
        Assert.Equal("decreasing", analytics.TrendMemory);
    }

    [Fact]
    public async Task GetAnalyticsAsync_When_No_Logs_Returns_Zeroes()
    {
        // Act
        var analytics = await _sut.GetAnalyticsAsync();

        // Assert
        Assert.Equal(0, analytics.TotalLogs);
        Assert.Equal(VitalService.RollingWindowSize, analytics.RollingWindowLogs);
        Assert.Equal(0, analytics.AverageThermal);
        Assert.Equal(0, analytics.AverageBattery);
        Assert.Equal(0, analytics.AverageMemory);
        Assert.Equal(0, analytics.MinThermal);
        Assert.Equal(0, analytics.MaxThermal);
        Assert.Equal(0, analytics.MinBattery);
        Assert.Equal(0, analytics.MaxBattery);
        Assert.Equal(0, analytics.MinMemory);
        Assert.Equal(0, analytics.MaxMemory);
        Assert.Equal("insufficient_data", analytics.TrendThermal);
        Assert.Equal("insufficient_data", analytics.TrendBattery);
        Assert.Equal("insufficient_data", analytics.TrendMemory);
    }

    [Fact]
    public async Task GetAnalyticsAsync_Calculates_Correct_Averages()
    {
        // Arrange - Create 5 vitals with known values
        var vitals = new[]
        {
            new DeviceVital { DeviceId = "d1", Timestamp = DateTime.UtcNow.AddMinutes(-5), ThermalValue = 0, BatteryLevel = 10, MemoryUsage = 20 },
            new DeviceVital { DeviceId = "d1", Timestamp = DateTime.UtcNow.AddMinutes(-4), ThermalValue = 1, BatteryLevel = 20, MemoryUsage = 30 },
            new DeviceVital { DeviceId = "d1", Timestamp = DateTime.UtcNow.AddMinutes(-3), ThermalValue = 2, BatteryLevel = 30, MemoryUsage = 40 },
            new DeviceVital { DeviceId = "d1", Timestamp = DateTime.UtcNow.AddMinutes(-2), ThermalValue = 3, BatteryLevel = 40, MemoryUsage = 50 },
            new DeviceVital { DeviceId = "d1", Timestamp = DateTime.UtcNow.AddMinutes(-1), ThermalValue = 1, BatteryLevel = 50, MemoryUsage = 60 }
        };

        foreach (var vital in vitals)
        {
            await _sut.LogVitalAsync(vital);
        }

        // Act
        var analytics = await _sut.GetAnalyticsAsync();

        // Assert
        Assert.Equal(5, analytics.TotalLogs);
        Assert.Equal(5, analytics.RollingWindowLogs);
        Assert.Equal(1.4, analytics.AverageThermal); // (0+1+2+3+1)/5 = 1.4
        Assert.Equal(30.0, analytics.AverageBattery); // (10+20+30+40+50)/5 = 30
        Assert.Equal(40.0, analytics.AverageMemory); // (20+30+40+50+60)/5 = 40
        Assert.Equal(0, analytics.MinThermal);
        Assert.Equal(3, analytics.MaxThermal);
        Assert.Equal(10.0, analytics.MinBattery);
        Assert.Equal(50.0, analytics.MaxBattery);
        Assert.Equal(20.0, analytics.MinMemory);
        Assert.Equal(60.0, analytics.MaxMemory);
        // Trends: newest first; recent half = first 2 (thermal 1,3; battery 50,40; memory 60,50), older half = last 3
        Assert.True(analytics.TrendThermal is "increasing" or "decreasing" or "stable");
        Assert.True(analytics.TrendBattery is "increasing" or "decreasing" or "stable");
        Assert.True(analytics.TrendMemory is "increasing" or "decreasing" or "stable");
    }
}
