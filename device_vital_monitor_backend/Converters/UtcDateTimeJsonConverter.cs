using System.Text.Json;
using System.Text.Json.Serialization;

namespace device_vital_monitor_backend.Converters;

/// <summary>
/// Ensures all API timestamp communication is in UTC: serializes as ISO8601 with "Z",
/// deserializes and normalizes to UTC (client must send UTC).
/// </summary>
public sealed class UtcDateTimeJsonConverter : JsonConverter<DateTime>
{
    public override DateTime Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        if (reader.TokenType != JsonTokenType.String)
            throw new JsonException("Expected string for DateTime (ISO8601 UTC).");

        var s = reader.GetString();
        if (string.IsNullOrEmpty(s))
            throw new JsonException("Timestamp cannot be null or empty.");

        if (!DateTime.TryParse(s, null, System.Globalization.DateTimeStyles.RoundtripKind, out var dt))
            throw new JsonException("Invalid timestamp format. Use ISO8601 UTC (e.g. 2024-01-15T10:30:00.000Z).");

        return dt.Kind == DateTimeKind.Utc ? dt : DateTime.SpecifyKind(dt, DateTimeKind.Utc);
    }

    public override void Write(Utf8JsonWriter writer, DateTime value, JsonSerializerOptions options)
    {
        // EF Core/SQLite returns DateTime with Kind=Unspecified; we store UTC, so treat Unspecified as UTC.
        // ToUniversalTime() on Unspecified would wrongly treat the value as local and shift it again.
        DateTime utc = value.Kind switch
        {
            DateTimeKind.Utc => value,
            DateTimeKind.Local => value.ToUniversalTime(),
            _ => DateTime.SpecifyKind(value, DateTimeKind.Utc)
        };
        writer.WriteStringValue(utc.ToString("O"));
    }
}

/// <summary>
/// Nullable variant for request DTOs (e.g. VitalLogRequest.Timestamp).
/// </summary>
public sealed class NullableUtcDateTimeJsonConverter : JsonConverter<DateTime?>
{
    private static readonly UtcDateTimeJsonConverter Inner = new();

    public override DateTime? Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        if (reader.TokenType == JsonTokenType.Null)
            return null;
        return Inner.Read(ref reader, typeToConvert, options);
    }

    public override void Write(Utf8JsonWriter writer, DateTime? value, JsonSerializerOptions options)
    {
        if (value == null)
            writer.WriteNullValue();
        else
            Inner.Write(writer, value.Value, options);
    }
}
