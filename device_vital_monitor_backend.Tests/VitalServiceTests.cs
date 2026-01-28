using device_vital_monitor_backend.Data;
using device_vital_monitor_backend.DTOs;
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
        _sut = new VitalService(_context);
    }

    public void Dispose() => _context.Dispose();

    private static VitalLogRequest ValidRequest(DateTime? timestamp = null) => new()
    {
        DeviceId = "device-1",
        Timestamp = timestamp ?? DateTime.UtcNow.AddMinutes(-1),
        ThermalValue = 1,
        BatteryLevel = 50.0,
        MemoryUsage = 60.0
    };

    [Fact]
    public async Task LogVitalAsync_Rejects_Null_Request()
    {
        var (success, error) = await _sut.LogVitalAsync(null!);
        Assert.False(success);
        Assert.NotNull(error);
        Assert.Contains("Request body", error);
    }

    [Fact]
    public async Task LogVitalAsync_Rejects_Missing_DeviceId()
    {
        var req = ValidRequest();
        req.DeviceId = null;
        var (success, error) = await _sut.LogVitalAsync(req);
        Assert.False(success);
        Assert.Contains("Device ID", error!);
    }

    [Fact]
    public async Task LogVitalAsync_Rejects_Empty_DeviceId()
    {
        var req = ValidRequest();
        req.DeviceId = "   ";
        var (success, error) = await _sut.LogVitalAsync(req);
        Assert.False(success);
        Assert.Contains("Device ID", error!);
    }

    [Fact]
    public async Task LogVitalAsync_Rejects_Missing_Timestamp()
    {
        var req = ValidRequest();
        req.Timestamp = null;
        var (success, error) = await _sut.LogVitalAsync(req);
        Assert.False(success);
        Assert.Contains("Timestamp", error!);
    }

    [Fact]
    public async Task LogVitalAsync_Rejects_Missing_ThermalValue()
    {
        var req = ValidRequest();
        req.ThermalValue = null;
        var (success, error) = await _sut.LogVitalAsync(req);
        Assert.False(success);
        Assert.Contains("Thermal", error!);
    }

    [Fact]
    public async Task LogVitalAsync_Rejects_Missing_BatteryLevel()
    {
        var req = ValidRequest();
        req.BatteryLevel = null;
        var (success, error) = await _sut.LogVitalAsync(req);
        Assert.False(success);
        Assert.Contains("Battery", error!);
    }

    [Fact]
    public async Task LogVitalAsync_Rejects_Missing_MemoryUsage()
    {
        var req = ValidRequest();
        req.MemoryUsage = null;
        var (success, error) = await _sut.LogVitalAsync(req);
        Assert.False(success);
        Assert.Contains("Memory", error!);
    }

    [Theory]
    [InlineData(-1)]
    [InlineData(4)]
    public async Task LogVitalAsync_Rejects_ThermalValue_OutOfRange(int value)
    {
        var req = ValidRequest();
        req.ThermalValue = value;
        var (success, error) = await _sut.LogVitalAsync(req);
        Assert.False(success);
        Assert.Contains("0 and 3", error!);
    }

    [Theory]
    [InlineData(-0.1)]
    [InlineData(100.1)]
    public async Task LogVitalAsync_Rejects_BatteryLevel_OutOfRange(double value)
    {
        var req = ValidRequest();
        req.BatteryLevel = value;
        var (success, error) = await _sut.LogVitalAsync(req);
        Assert.False(success);
        Assert.Contains("0 and 100", error!);
    }

    [Theory]
    [InlineData(-1.0)]
    [InlineData(101.0)]
    public async Task LogVitalAsync_Rejects_MemoryUsage_OutOfRange(double value)
    {
        var req = ValidRequest();
        req.MemoryUsage = value;
        var (success, error) = await _sut.LogVitalAsync(req);
        Assert.False(success);
        Assert.Contains("0 and 100", error!);
    }

    [Fact]
    public async Task LogVitalAsync_Rejects_Future_Timestamp()
    {
        var req = ValidRequest(DateTime.UtcNow.AddHours(1));
        var (success, error) = await _sut.LogVitalAsync(req);
        Assert.False(success);
        Assert.Contains("future", error!);
    }

    [Fact]
    public async Task LogVitalAsync_Accepts_Valid_Request()
    {
        var req = ValidRequest();
        var (success, error) = await _sut.LogVitalAsync(req);
        Assert.True(success);
        Assert.Null(error);
        Assert.Equal(1, await _context.DeviceVitals.CountAsync());
    }

    [Fact]
    public async Task GetAnalyticsAsync_RollingAverage_Uses_Last_100_Logs_Only()
    {
        var baseTime = DateTime.UtcNow.AddHours(-2);
        // Insert 50 logs with thermal=2, then 100 logs with thermal=1 (most recent)
        for (int i = 0; i < 50; i++)
        {
            await _sut.LogVitalAsync(new VitalLogRequest
            {
                DeviceId = "d1",
                Timestamp = baseTime.AddSeconds(i),
                ThermalValue = 2,
                BatteryLevel = 50,
                MemoryUsage = 50
            });
        }
        for (int i = 0; i < 100; i++)
        {
            await _sut.LogVitalAsync(new VitalLogRequest
            {
                DeviceId = "d1",
                Timestamp = baseTime.AddMinutes(1).AddSeconds(i),
                ThermalValue = 1,
                BatteryLevel = 50,
                MemoryUsage = 50
            });
        }
        // Last 100 all have thermal=1, so rolling average thermal must be 1.0
        var analytics = await _sut.GetAnalyticsAsync();
        Assert.Equal(150, analytics.TotalLogs);
        Assert.Equal(100, analytics.RollingWindowLogs);
        Assert.Equal(1.0, analytics.AverageThermal);
        Assert.Equal(50.0, analytics.AverageBattery);
        Assert.Equal(50.0, analytics.AverageMemory);
    }

    [Fact]
    public async Task GetAnalyticsAsync_When_Fewer_Than_100_Logs_Returns_All()
    {
        await _sut.LogVitalAsync(ValidRequest());
        var req2 = ValidRequest();
        req2.ThermalValue = 3;
        req2.BatteryLevel = 80;
        req2.MemoryUsage = 40;
        await _sut.LogVitalAsync(req2);
        var analytics = await _sut.GetAnalyticsAsync();
        Assert.Equal(2, analytics.TotalLogs);
        Assert.Equal(2, analytics.RollingWindowLogs);
        Assert.Equal(2.0, analytics.AverageThermal); // (1+3)/2
        Assert.Equal(65.0, analytics.AverageBattery);
        Assert.Equal(50.0, analytics.AverageMemory);
    }

    [Fact]
    public async Task GetAnalyticsAsync_When_No_Logs_Returns_Zeroes()
    {
        var analytics = await _sut.GetAnalyticsAsync();
        Assert.Equal(0, analytics.TotalLogs);
        Assert.Equal(VitalService.RollingWindowSize, analytics.RollingWindowLogs);
        Assert.Equal(0, analytics.AverageThermal);
        Assert.Equal(0, analytics.AverageBattery);
        Assert.Equal(0, analytics.AverageMemory);
    }
}
