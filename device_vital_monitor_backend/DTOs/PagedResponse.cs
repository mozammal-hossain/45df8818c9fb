using System.Text.Json.Serialization;

namespace device_vital_monitor_backend.DTOs
{
    public class PagedResponse<T>
    {
        [JsonPropertyName("data")]
        public IEnumerable<T> Data { get; set; } = Enumerable.Empty<T>();

        [JsonPropertyName("page")]
        public int Page { get; set; }

        [JsonPropertyName("page_size")]
        public int PageSize { get; set; }

        [JsonPropertyName("total_count")]
        public int TotalCount { get; set; }

        [JsonPropertyName("total_pages")]
        public int TotalPages { get; set; }

        [JsonPropertyName("has_next_page")]
        public bool HasNextPage { get; set; }

        [JsonPropertyName("has_previous_page")]
        public bool HasPreviousPage { get; set; }
    }
}
