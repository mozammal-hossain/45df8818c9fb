using device_vital_monitor_backend.Controllers;
using device_vital_monitor_backend.DTOs;
using device_vital_monitor_backend.Models;
using device_vital_monitor_backend.Services;
using Microsoft.AspNetCore.Mvc;
using Moq;

namespace device_vital_monitor_backend.Tests;

public class VitalsControllerTests
{
    private readonly Mock<IVitalService> _mockService;
    private readonly VitalsController _controller;

    public VitalsControllerTests()
    {
        _mockService = new Mock<IVitalService>();
        _controller = new VitalsController(_mockService.Object);
    }

    private static VitalLogRequest CreateValidRequest(DateTime? timestamp = null) => new()
    {
        DeviceId = "device-1",
        Timestamp = timestamp ?? DateTime.UtcNow.AddMinutes(-1),
        ThermalValue = 1,
        BatteryLevel = 50.0,
        MemoryUsage = 60.0
    };

    [Fact]
    public async Task POST_LogVital_With_Valid_Data_Returns_Created()
    {
        // Arrange
        var request = CreateValidRequest();
        var savedVital = new DeviceVital
        {
            Id = 1,
            DeviceId = request.DeviceId!,
            Timestamp = request.Timestamp!.Value,
            ThermalValue = request.ThermalValue!.Value,
            BatteryLevel = request.BatteryLevel!.Value,
            MemoryUsage = request.MemoryUsage!.Value
        };

        _mockService.Setup(s => s.LogVitalAsync(It.IsAny<DeviceVital>()))
            .ReturnsAsync(savedVital);

        // Act
        var result = await _controller.LogVital(request);

        // Assert
        var createdAtResult = Assert.IsType<CreatedResult>(result);
        Assert.Equal($"/api/vitals/{savedVital.Id}", createdAtResult.Location);
        _mockService.Verify(s => s.LogVitalAsync(It.Is<DeviceVital>(v =>
            v.DeviceId == request.DeviceId &&
            v.ThermalValue == request.ThermalValue &&
            v.BatteryLevel == request.BatteryLevel &&
            v.MemoryUsage == request.MemoryUsage)), Times.Once);
    }

    [Fact]
    public async Task POST_LogVital_With_Null_Request_Returns_BadRequest()
    {
        // Act
        var result = await _controller.LogVital(null!);

        // Assert
        var badRequestResult = Assert.IsType<BadRequestObjectResult>(result);
        Assert.Contains("Invalid request", badRequestResult.Value!.ToString()!, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task POST_LogVital_With_Missing_DeviceId_Returns_BadRequest()
    {
        // Arrange
        var request = CreateValidRequest();
        request.DeviceId = null;

        // Act
        var result = await _controller.LogVital(request);

        // Assert
        var badRequestResult = Assert.IsType<BadRequestObjectResult>(result);
        Assert.Contains("Device ID", badRequestResult.Value!.ToString()!, StringComparison.OrdinalIgnoreCase);
        _mockService.Verify(s => s.LogVitalAsync(It.IsAny<DeviceVital>()), Times.Never);
    }

    [Fact]
    public async Task POST_LogVital_With_Empty_DeviceId_Returns_BadRequest()
    {
        // Arrange
        var request = CreateValidRequest();
        request.DeviceId = "   ";

        // Act
        var result = await _controller.LogVital(request);

        // Assert
        var badRequestResult = Assert.IsType<BadRequestObjectResult>(result);
        Assert.Contains("Device ID", badRequestResult.Value!.ToString()!, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task POST_LogVital_With_Missing_Timestamp_Returns_BadRequest()
    {
        // Arrange
        var request = CreateValidRequest();
        request.Timestamp = null;

        // Act
        var result = await _controller.LogVital(request);

        // Assert
        var badRequestResult = Assert.IsType<BadRequestObjectResult>(result);
        Assert.Contains("Timestamp", badRequestResult.Value!.ToString()!, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task POST_LogVital_With_Missing_ThermalValue_Returns_BadRequest()
    {
        // Arrange
        var request = CreateValidRequest();
        request.ThermalValue = null;

        // Act
        var result = await _controller.LogVital(request);

        // Assert
        var badRequestResult = Assert.IsType<BadRequestObjectResult>(result);
        Assert.Contains("Thermal", badRequestResult.Value!.ToString()!, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task POST_LogVital_With_Missing_BatteryLevel_Returns_BadRequest()
    {
        // Arrange
        var request = CreateValidRequest();
        request.BatteryLevel = null;

        // Act
        var result = await _controller.LogVital(request);

        // Assert
        var badRequestResult = Assert.IsType<BadRequestObjectResult>(result);
        Assert.Contains("Battery", badRequestResult.Value!.ToString()!, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task POST_LogVital_With_Missing_MemoryUsage_Returns_BadRequest()
    {
        // Arrange
        var request = CreateValidRequest();
        request.MemoryUsage = null;

        // Act
        var result = await _controller.LogVital(request);

        // Assert
        var badRequestResult = Assert.IsType<BadRequestObjectResult>(result);
        Assert.Contains("Memory", badRequestResult.Value!.ToString()!, StringComparison.OrdinalIgnoreCase);
    }

    [Theory]
    [InlineData(-1)]
    [InlineData(4)]
    public async Task POST_LogVital_With_ThermalValue_OutOfRange_Returns_BadRequest(int thermalValue)
    {
        // Arrange
        var request = CreateValidRequest();
        request.ThermalValue = thermalValue;

        // Act
        var result = await _controller.LogVital(request);

        // Assert
        var badRequestResult = Assert.IsType<BadRequestObjectResult>(result);
        Assert.Contains("0 and 3", badRequestResult.Value!.ToString()!);
    }

    [Theory]
    [InlineData(-0.1)]
    [InlineData(100.1)]
    public async Task POST_LogVital_With_BatteryLevel_OutOfRange_Returns_BadRequest(double batteryLevel)
    {
        // Arrange
        var request = CreateValidRequest();
        request.BatteryLevel = batteryLevel;

        // Act
        var result = await _controller.LogVital(request);

        // Assert
        var badRequestResult = Assert.IsType<BadRequestObjectResult>(result);
        Assert.Contains("0 and 100", badRequestResult.Value!.ToString()!);
    }

    [Theory]
    [InlineData(-1.0)]
    [InlineData(101.0)]
    public async Task POST_LogVital_With_MemoryUsage_OutOfRange_Returns_BadRequest(double memoryUsage)
    {
        // Arrange
        var request = CreateValidRequest();
        request.MemoryUsage = memoryUsage;

        // Act
        var result = await _controller.LogVital(request);

        // Assert
        var badRequestResult = Assert.IsType<BadRequestObjectResult>(result);
        Assert.Contains("0 and 100", badRequestResult.Value!.ToString()!);
    }

    [Fact]
    public async Task POST_LogVital_With_Future_Timestamp_Returns_BadRequest()
    {
        // Arrange
        var request = CreateValidRequest(DateTime.UtcNow.AddHours(10));

        // Act
        var result = await _controller.LogVital(request);

        // Assert
        var badRequestResult = Assert.IsType<BadRequestObjectResult>(result);
        Assert.Contains("future", badRequestResult.Value!.ToString()!, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task GET_GetHistory_Without_PageSize_Defaults_To_100()
    {
        // Arrange
        var vitals = new List<DeviceVital>
        {
            new() { Id = 1, DeviceId = "device-1", Timestamp = DateTime.UtcNow, ThermalValue = 1, BatteryLevel = 50, MemoryUsage = 50 }
        };
        var pagedResponse = new PagedResponse<DeviceVital>
        {
            Data = vitals,
            Page = 1,
            PageSize = 100,
            TotalCount = 1,
            TotalPages = 1,
            HasNextPage = false,
            HasPreviousPage = false
        };

        _mockService.Setup(s => s.GetHistoryAsync(1, 100))
            .ReturnsAsync(pagedResponse);

        // Act
        var result = await _controller.GetHistory();

        // Assert
        var okResult = Assert.IsType<OkObjectResult>(result);
        var response = Assert.IsType<PagedResponse<DeviceVital>>(okResult.Value);
        Assert.Equal(100, response.PageSize);
        _mockService.Verify(s => s.GetHistoryAsync(1, 100), Times.Once);
    }

    [Fact]
    public async Task GET_GetHistory_With_Custom_PageSize_Uses_Provided_Value()
    {
        // Arrange
        var pagedResponse = new PagedResponse<DeviceVital>
        {
            Data = new List<DeviceVital>(),
            Page = 2,
            PageSize = 25,
            TotalCount = 50,
            TotalPages = 2,
            HasNextPage = false,
            HasPreviousPage = true
        };

        _mockService.Setup(s => s.GetHistoryAsync(2, 25))
            .ReturnsAsync(pagedResponse);

        // Act
        var result = await _controller.GetHistory(page: 2, pageSize: 25);

        // Assert
        var okResult = Assert.IsType<OkObjectResult>(result);
        var response = Assert.IsType<PagedResponse<DeviceVital>>(okResult.Value);
        Assert.Equal(25, response.PageSize);
        _mockService.Verify(s => s.GetHistoryAsync(2, 25), Times.Once);
    }

    [Fact]
    public async Task GET_GetHistory_With_Invalid_Page_Returns_BadRequest()
    {
        // Act
        var result = await _controller.GetHistory(page: 0);

        // Assert
        var badRequestResult = Assert.IsType<BadRequestObjectResult>(result);
        Assert.Contains("Page must be greater than or equal to 1", badRequestResult.Value!.ToString()!);
    }

    [Fact]
    public async Task GET_GetHistory_With_Invalid_PageSize_Returns_BadRequest()
    {
        // Act
        var result = await _controller.GetHistory(pageSize: 0);

        // Assert
        var badRequestResult = Assert.IsType<BadRequestObjectResult>(result);
        Assert.Contains("Page size must be between 1 and 1000", badRequestResult.Value!.ToString()!);
    }

    [Fact]
    public async Task GET_GetAnalytics_Returns_Analytics_Data()
    {
        // Arrange
        var analytics = new AnalyticsResult
        {
            TotalLogs = 5,
            RollingWindowLogs = 5,
            AverageThermal = 1.4,
            AverageBattery = 30.0,
            AverageMemory = 40.0
        };

        _mockService.Setup(s => s.GetAnalyticsAsync())
            .ReturnsAsync(analytics);

        // Act
        var result = await _controller.GetAnalytics();

        // Assert
        var okResult = Assert.IsType<OkObjectResult>(result);
        var response = Assert.IsType<AnalyticsResult>(okResult.Value);
        Assert.Equal(5, response.TotalLogs);
        Assert.Equal(5, response.RollingWindowLogs);
        Assert.Equal(1.4, response.AverageThermal);
        _mockService.Verify(s => s.GetAnalyticsAsync(), Times.Once);
    }
}
