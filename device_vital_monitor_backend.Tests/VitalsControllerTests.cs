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
        var errorResponse = Assert.IsType<ErrorResponse>(badRequestResult.Value);
        Assert.Contains("Invalid request", errorResponse.Error, StringComparison.OrdinalIgnoreCase);
        Assert.Equal("INVALID_REQUEST", errorResponse.Code);
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
        var errorResponse = Assert.IsType<ErrorResponse>(badRequestResult.Value);
        Assert.Contains("Device ID", errorResponse.Error, StringComparison.OrdinalIgnoreCase);
        Assert.Equal("device_id", errorResponse.Field);
        Assert.Equal("MISSING_FIELD", errorResponse.Code);
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
        var errorResponse = Assert.IsType<ErrorResponse>(badRequestResult.Value);
        Assert.Contains("Device ID", errorResponse.Error, StringComparison.OrdinalIgnoreCase);
        Assert.Equal("device_id", errorResponse.Field);
        Assert.Equal("MISSING_FIELD", errorResponse.Code);
    }

    [Fact]
    public async Task POST_LogVital_With_EmptyString_DeviceId_Returns_BadRequest()
    {
        // Arrange
        var request = CreateValidRequest();
        request.DeviceId = string.Empty;

        // Act
        var result = await _controller.LogVital(request);

        // Assert
        var badRequestResult = Assert.IsType<BadRequestObjectResult>(result);
        var errorResponse = Assert.IsType<ErrorResponse>(badRequestResult.Value);
        Assert.Contains("Device ID", errorResponse.Error, StringComparison.OrdinalIgnoreCase);
        Assert.Equal("device_id", errorResponse.Field);
        Assert.Equal("MISSING_FIELD", errorResponse.Code);
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
        var errorResponse = Assert.IsType<ErrorResponse>(badRequestResult.Value);
        Assert.Contains("0 and 3", errorResponse.Error);
        Assert.Equal("thermal_value", errorResponse.Field);
        Assert.Equal("INVALID_RANGE", errorResponse.Code);
    }

    [Theory]
    [InlineData(0)]
    [InlineData(3)]
    public async Task POST_LogVital_With_ThermalValue_BoundaryValues_Returns_Created(int thermalValue)
    {
        // Arrange
        var request = CreateValidRequest();
        request.ThermalValue = thermalValue;
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
        var errorResponse = Assert.IsType<ErrorResponse>(badRequestResult.Value);
        Assert.Contains("0 and 100", errorResponse.Error);
        Assert.Equal("battery_level", errorResponse.Field);
        Assert.Equal("INVALID_RANGE", errorResponse.Code);
    }

    [Theory]
    [InlineData(0.0)]
    [InlineData(100.0)]
    public async Task POST_LogVital_With_BatteryLevel_BoundaryValues_Returns_Created(double batteryLevel)
    {
        // Arrange
        var request = CreateValidRequest();
        request.BatteryLevel = batteryLevel;
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
        var errorResponse = Assert.IsType<ErrorResponse>(badRequestResult.Value);
        Assert.Contains("0 and 100", errorResponse.Error);
        Assert.Equal("memory_usage", errorResponse.Field);
        Assert.Equal("INVALID_RANGE", errorResponse.Code);
    }

    [Theory]
    [InlineData(0.0)]
    [InlineData(100.0)]
    public async Task POST_LogVital_With_MemoryUsage_BoundaryValues_Returns_Created(double memoryUsage)
    {
        // Arrange
        var request = CreateValidRequest();
        request.MemoryUsage = memoryUsage;
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
        var errorResponse = Assert.IsType<ErrorResponse>(badRequestResult.Value);
        Assert.Contains("future", errorResponse.Error, StringComparison.OrdinalIgnoreCase);
        Assert.Equal("timestamp", errorResponse.Field);
        Assert.Equal("INVALID_TIMESTAMP", errorResponse.Code);
    }

    [Fact]
    public async Task POST_LogVital_With_Timestamp_Exactly_5_Minutes_In_Future_Returns_Created()
    {
        // Arrange - Exactly 5 minutes in future should pass (clock skew tolerance)
        var request = CreateValidRequest(DateTime.UtcNow.AddMinutes(5));
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
    }

    [Fact]
    public async Task POST_LogVital_With_Timestamp_5_Minutes_1_Second_In_Future_Returns_BadRequest()
    {
        // Arrange - 5 minutes + 1 second should fail
        var request = CreateValidRequest(DateTime.UtcNow.AddMinutes(5).AddSeconds(1));

        // Act
        var result = await _controller.LogVital(request);

        // Assert
        var badRequestResult = Assert.IsType<BadRequestObjectResult>(result);
        var errorResponse = Assert.IsType<ErrorResponse>(badRequestResult.Value);
        Assert.Contains("future", errorResponse.Error, StringComparison.OrdinalIgnoreCase);
        Assert.Equal("timestamp", errorResponse.Field);
        Assert.Equal("INVALID_TIMESTAMP", errorResponse.Code);
    }

    [Fact]
    public async Task GET_GetHistory_Without_PageSize_Defaults_To_20()
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
            PageSize = 20,
            TotalCount = 1,
            TotalPages = 1,
            HasNextPage = false,
            HasPreviousPage = false
        };

        _mockService.Setup(s => s.GetHistoryAsync(1, 20))
            .ReturnsAsync(pagedResponse);

        // Act
        var result = await _controller.GetHistory();

        // Assert
        var okResult = Assert.IsType<OkObjectResult>(result);
        var response = Assert.IsType<PagedResponse<DeviceVital>>(okResult.Value);
        Assert.Equal(20, response.PageSize);
        _mockService.Verify(s => s.GetHistoryAsync(1, 20), Times.Once);
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
        var errorResponse = Assert.IsType<ErrorResponse>(badRequestResult.Value);
        Assert.Contains("Page must be greater than or equal to 1", errorResponse.Error);
        Assert.Equal("page", errorResponse.Field);
        Assert.Equal("INVALID_RANGE", errorResponse.Code);
    }

    [Fact]
    public async Task GET_GetHistory_With_Invalid_PageSize_TooSmall_Returns_BadRequest()
    {
        // Act
        var result = await _controller.GetHistory(pageSize: 0);

        // Assert
        var badRequestResult = Assert.IsType<BadRequestObjectResult>(result);
        var errorResponse = Assert.IsType<ErrorResponse>(badRequestResult.Value);
        Assert.Contains("Page size must be between 1 and 100", errorResponse.Error);
        Assert.Equal("pageSize", errorResponse.Field);
        Assert.Equal("INVALID_RANGE", errorResponse.Code);
    }

    [Fact]
    public async Task GET_GetHistory_With_Invalid_PageSize_TooLarge_Returns_BadRequest()
    {
        // Act
        var result = await _controller.GetHistory(pageSize: 101);

        // Assert
        var badRequestResult = Assert.IsType<BadRequestObjectResult>(result);
        var errorResponse = Assert.IsType<ErrorResponse>(badRequestResult.Value);
        Assert.Contains("Page size must be between 1 and 100", errorResponse.Error);
        Assert.Equal("pageSize", errorResponse.Field);
        Assert.Equal("INVALID_RANGE", errorResponse.Code);
    }

    [Fact]
    public async Task GET_GetHistory_With_PageSize_At_Maximum_100_Returns_Ok()
    {
        // Arrange
        var pagedResponse = new PagedResponse<DeviceVital>
        {
            Data = new List<DeviceVital>(),
            Page = 1,
            PageSize = 100,
            TotalCount = 0,
            TotalPages = 0,
            HasNextPage = false,
            HasPreviousPage = false
        };

        _mockService.Setup(s => s.GetHistoryAsync(1, 100))
            .ReturnsAsync(pagedResponse);

        // Act
        var result = await _controller.GetHistory(pageSize: 100);

        // Assert
        var okResult = Assert.IsType<OkObjectResult>(result);
        var response = Assert.IsType<PagedResponse<DeviceVital>>(okResult.Value);
        Assert.Equal(100, response.PageSize);
        _mockService.Verify(s => s.GetHistoryAsync(1, 100), Times.Once);
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
            AverageMemory = 40.0,
            MinThermal = 0,
            MaxThermal = 3,
            MinBattery = 10.0,
            MaxBattery = 50.0,
            MinMemory = 20.0,
            MaxMemory = 60.0,
            TrendThermal = "stable",
            TrendBattery = "increasing",
            TrendMemory = "decreasing"
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
