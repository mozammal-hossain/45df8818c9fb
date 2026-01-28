namespace device_vital_monitor_backend.Middleware;

public class RequestLoggingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<RequestLoggingMiddleware> _logger;

    public RequestLoggingMiddleware(RequestDelegate next, ILogger<RequestLoggingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var startTicks = Environment.TickCount64;
        var method = context.Request.Method;
        var path = context.Request.Path;
        var queryString = context.Request.QueryString.HasValue ? context.Request.QueryString.Value : "";

        _logger.LogInformation(
            "Request started: {Method} {Path}{QueryString}",
            method,
            path,
            queryString);

        try
        {
            await _next(context);
        }
        finally
        {
            var elapsedMs = Environment.TickCount64 - startTicks;
            var statusCode = context.Response.StatusCode;

            _logger.LogInformation(
                "Request completed: {Method} {Path} -> {StatusCode} in {ElapsedMs}ms",
                method,
                path,
                statusCode,
                elapsedMs);
        }
    }
}
