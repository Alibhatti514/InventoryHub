using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.OutputCaching;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddCors(options =>
{
    options.AddPolicy("Client", policy =>
    {
        policy.WithOrigins("http://localhost:5100")
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

builder.Services.ConfigureHttpJsonOptions(options =>
{
    options.SerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
    options.SerializerOptions.DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull;
});

builder.Services.AddOutputCache(options =>
    options.AddPolicy("products", policy => policy.Expire(TimeSpan.FromSeconds(30))));

var app = builder.Build();

app.UseCors("Client");
app.UseOutputCache();

app.MapGet("/api/productlist", () => Results.Ok(ProductCatalog.Items)).CacheOutput("products");
app.MapGet("/health", () => Results.Ok(new { status = "ok" }));

app.Run();

public static class ProductCatalog
{
    public static Product[] Items { get; } =
    [
        new Product(1, "Laptop", 1200.50m, 25, new Category(101, "Electronics")),
        new Product(2, "Headphones", 50.00m, 100, new Category(102, "Accessories"))
    ];
}

public record Category(int Id, string Name);
public record Product(int Id, string Name, decimal Price, int Stock, Category Category);
