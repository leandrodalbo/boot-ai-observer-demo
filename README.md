# boot-ai-observer-demo

A ready-to-run Spring Boot application that demonstrates [boot-ai-observer](../boot-ai-observer/README.md) in action. It exposes endpoints that simulate common production problems — memory pressure, slow responses, and unhandled exceptions — so you can watch the AI observer detect and explain them.

## What the demo does

The demo app has four endpoints:

| Endpoint     | Behavior                                                                |
| ------------ | ----------------------------------------------------------------------- |
| `GET /hello` | Returns a greeting — normal, healthy traffic                            |
| `GET /slow`  | Sleeps 2 seconds before responding — simulates latency                  |
| `GET /error` | Throws a `RuntimeException` — feeds the error collector                 |
| `GET /leak`  | Allocates ~1 MB of heap per call (max 500 MB) — simulates a memory leak |

The included `demo.sh` script hits all four endpoints in sequence, then waits for the AI observer to analyze the resulting JVM state and prints the insight.

## Requirements

- Java 21+
- Maven 3.8+
- An [Anthropic API key](https://console.anthropic.com/) (Claude is the default provider)
- `boot-ai-observer` installed locally (see step 1 below)

## Running the demo

### Step 1 — Install the starter library

The starter is not yet on Maven Central, so you need to build and install it locally first:

```bash
git clone https://github.com/your-org/boot-ai-observer.git
cd boot-ai-observer
mvn clean install
```

### Step 2 — Clone the demo app

```bash
git clone https://github.com/your-org/boot-ai-observer-demo.git
cd boot-ai-observer-demo
```

### Step 3 — Start the application

```bash
ANTHROPIC_API_KEY=your-key-here mvn spring-boot:run
```

The app starts on port `8080`. You should see log output confirming the AI observer is active:

```
[AI Observer] Starting with provider=CLAUDE, model=claude-haiku-4-5-20251001, interval=60s
```

### Step 4 — Run the demo script

In a separate terminal, from the demo directory:

```bash
bash demo.sh
```

The script will:

1. Send 5 normal requests to `/hello`
2. Send 3 slow requests to `/slow` (2s each)
3. Send 5 error requests to `/error`
4. Send 20 leak requests to `/leak` (to push heap above the 70% threshold)
5. Wait 10 seconds for the observer to react
6. Fetch and display the AI insight from `/actuator/ai-insight`

### Step 5 — Check the insight manually

At any time you can call the insight endpoint directly:

```bash
curl http://localhost:8080/actuator/ai-insight | jq
```

Example output after running the demo script:

```json
{
  "insight": "Heap usage is at 78% (threshold: 70%) — this was likely triggered by repeated calls to /leak. Five recent exceptions of type RuntimeException were captured from the /error endpoint. The /slow endpoint shows an average latency of 2012ms across 3 requests, which is significantly above normal. Consider investigating the memory allocation pattern on /leak and adding error handling on /error.",
  "generatedAt": "2026-03-22T10:15:32"
}
```

## Demo configuration

The demo is pre-configured in `src/main/resources/application.yml` with aggressive settings to make results visible quickly:

| Setting                         | Demo value                  | Default |
| ------------------------------- | --------------------------- | ------- |
| `interval-seconds`              | `60`                        | `900`   |
| `thresholds.heap-usage-percent` | `70`                        | `80`    |
| `ai-model`                      | `claude-haiku-4-5-20251001` | same    |

The lower heap threshold (70%) and short interval (60s) mean you will see insights within a minute of running the script, rather than waiting 15 minutes.

## Trying different providers

To use OpenAI instead of Claude, update `application.yml`:

```yaml
ai:
  observer:
    ai-provider: openai
    ai-api-key: ${OPENAI_API_KEY}
    ai-model: gpt-4o-mini
```

Then start the app with:

```bash
OPENAI_API_KEY=your-key-here mvn spring-boot:run
```

## Project structure

```
boot-ai-observer-demo/
├── src/main/java/boot/ai/observer/demo/
│   ├── BootAiObserverDemoApplication.java   # @SpringBootApplication entry point
│   └── DemoController.java                 # /hello, /slow, /error, /leak endpoints
├── src/main/resources/
│   └── application.yml                     # Pre-configured for the demo
└── demo.sh                                 # Script that drives the demo scenario
```

## Next steps

Once you have verified the demo works, integrate the starter into your own Spring Boot app:

1. Add the `boot-ai-observer` dependency to your `pom.xml`
2. Set your API key
3. Add `ai.observer.ai-provider` and `ai.observer.ai-api-key` to your `application.yml`
4. Optionally add `prompt.extra-context` to describe your app to the AI

See the [boot-ai-observer README](../boot-ai-observer/README.md) for the full configuration reference.
