# InventoryHub

InventoryHub is a .NET 10 sample application that demonstrates a Blazor WebAssembly frontend consuming a minimal ASP.NET Core API. The project emphasizes clean full-stack communication, nested JSON models, output caching, and local CORS restrictions suitable for a development environment.

## Technologies used
- .NET 10 SDK
- ASP.NET Core 10 Minimal API
- Blazor WebAssembly
- C# 13 / .NET 10 features
- JSON serialization with camelCase naming
- Bash-based smoke tests

## Application architecture
The application is split into two projects:
- `ClientApp` hosts the Blazor UI and sends HTTP requests to the API.
- `ServerApp` exposes the product data and applies CORS and output caching.

The UI route is `/fetchproducts` and the API route is `/api/productlist`. The server also exposes `/health` for readiness checks.

## Frontend features
- Typed deserialization with `HttpClient`
- Refresh button with a loading indicator
- Graceful handling for network failures and malformed JSON
- Timeout messaging for slow responses
- Request guard to prevent overlapping fetches
- Clear table rendering for product, category, price, and stock

## Backend features
- Minimal API endpoint at `/api/productlist`
- Strict CORS policy scoped to `http://localhost:5100`
- 30-second output cache for the product response
- Strongly typed `Product` and `Category` records
- CamelCase JSON serialization alignment with the Blazor client

## API endpoint documentation
### Health check
`GET http://localhost:5101/health`
Returns:
```json
{ "status": "ok" }
```

### Product list
`GET http://localhost:5101/api/productlist`
Returns an array of product objects.

## JSON response example
```json
[
  {
    "id": 1,
    "name": "Laptop",
    "price": 1200.5,
    "stock": 25,
    "category": {
      "id": 101,
      "name": "Electronics"
    }
  },
  {
    "id": 2,
    "name": "Headphones",
    "price": 50,
    "stock": 100,
    "category": {
      "id": 102,
      "name": "Accessories"
    }
  }
]
```

## Local installation
Prerequisites:
- Install the .NET 10 SDK.
- Ensure you can run `dotnet --version` successfully.

From the repository root:
```bash
dotnet restore InventoryHub.slnx
dotnet build InventoryHub.slnx
```

## Run the frontend and backend
Open two terminals in the project root.

Terminal 1:
```bash
dotnet run --project ServerApp --launch-profile http
```

Terminal 2:
```bash
dotnet run --project ClientApp --urls http://localhost:5100
```

Then browse to:
- `http://localhost:5100/fetchproducts`
- API: `http://localhost:5101/api/productlist`

## Automated testing
While the backend is running, run:
```bash
bash tests/smoke.sh
```

The smoke script verifies:
- health endpoint availability
- successful `200 OK` product request
- valid JSON array structure
- nested category object data
- numeric prices and stock values
- CORS response headers
- invalid route handling
- cache consistency across repeated requests

## CORS configuration
The API allows only the local Blazor development origin:
```text
http://localhost:5100
```

This is intentionally restricted rather than using wildcard origins.

## Performance optimization details
The application keeps the product response in ASP.NET Core output cache for 30 seconds. This is useful for small in-memory sample data and avoids repeated response generation during rapid refreshes. The Blazor UI also prevents overlapping API requests and reads the JSON payload once, reducing unnecessary rendering and duplicate network traffic.

Measured behavior is limited to response consistency checks in this environment; the app is intentionally small enough that micro-benchmarks would not be as meaningful as the functional and caching smoke checks.

## Troubleshooting
- If the API port is already in use, stop the previous instance or choose a different configuration.
- If the frontend cannot reach the backend, verify both projects are running and the server is listening on port `5101`.
- If the page shows an error, confirm the browser origin matches `http://localhost:5100` and the API CORS policy is active.
- If JSON deserialization fails, inspect the response body to ensure the payload matches the expected `Product[]` structure.

## GitHub repository information
This repository currently has no configured Git remote. A public repository can be created only after explicit user approval. A local Git repository is preserved in this workspace.
