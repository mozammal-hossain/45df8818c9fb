using System.Text.Json.Serialization;
using System.Threading.RateLimiting;
using device_vital_monitor_backend.Converters;
using device_vital_monitor_backend.Data;
using device_vital_monitor_backend.DTOs;
using device_vital_monitor_backend.Middleware;
using device_vital_monitor_backend.Repositories;
using device_vital_monitor_backend.Services;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container. Timestamps: API uses UTC (serialize/deserialize).
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.Converters.Add(new UtcDateTimeJsonConverter());
        options.JsonSerializerOptions.Converters.Add(new NullableUtcDateTimeJsonConverter());
    });
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();

// Add CORS support for Flutter app
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

// Rate limiting: fixed window per IP, configurable via appsettings
var rateLimitSection = builder.Configuration.GetSection("RateLimiting");
var permitLimit = rateLimitSection.GetValue("PermitLimit", 100);
var windowSeconds = rateLimitSection.GetValue("WindowSeconds", 60);

builder.Services.AddRateLimiter(options =>
{
    options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
    options.OnRejected = async (context, cancellationToken) =>
    {
        context.HttpContext.Response.ContentType = "application/json";
        var response = new ErrorResponse(
            "Too many requests. Please try again later.",
            field: null,
            code: "RATE_LIMIT_EXCEEDED");
        await context.HttpContext.Response.WriteAsJsonAsync(response, cancellationToken);
    };
    options.AddPolicy("api", context =>
    {
        var clientIp = context.Connection.RemoteIpAddress?.ToString() ?? "unknown";
        return RateLimitPartition.GetFixedWindowLimiter(clientIp, _ => new FixedWindowRateLimiterOptions
        {
            PermitLimit = permitLimit,
            Window = TimeSpan.FromSeconds(windowSeconds),
            QueueProcessingOrder = QueueProcessingOrder.OldestFirst,
            QueueLimit = 0,
            AutoReplenishment = true
        });
    });
});

builder.Services.AddDbContext<VitalContext>(options =>
    options.UseSqlite(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddScoped<IDeviceVitalRepository, DeviceVitalRepository>();
builder.Services.AddScoped<IVitalService, VitalService>();


var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();

app.UseMiddleware<RequestLoggingMiddleware>();

app.UseCors();

app.UseRateLimiter();

app.UseAuthorization();

app.MapControllers()
    .RequireRateLimiting("api");

// Ensure database is created
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<VitalContext>();
    context.Database.EnsureCreated();
}

app.Run();
