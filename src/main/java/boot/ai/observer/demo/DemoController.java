package boot.ai.observer.demo;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.List;

@RestController
public class DemoController
{

    /**
     * Simulates a memory leak — each call allocates 1 MB in a static list (capped at 500 MB).
     * Hit this endpoint repeatedly to trigger the heap threshold and watch AI Observer react.
     */
    private static final List<byte[]> LEAK     = new ArrayList<>();
    private static final int          MAX_MB   = 500;

    @GetMapping("/hello")
    public String hello() {
        return "Hello from AI Observer Demo!";
    }

    @GetMapping("/leak")
    public String leak() {
        if (LEAK.size() < MAX_MB) {
            LEAK.add(new byte[1_000_000]);
        }
        return "Heap pressure: " + LEAK.size() + " MB allocated (max " + MAX_MB + " MB)";
    }

    @GetMapping("/slow")
    public String slow() throws InterruptedException {
        Thread.sleep(2_000);
        return "Slow response — 2s latency recorded by AI Observer";
    }

    @GetMapping("/error")
    public String error() {
        throw new RuntimeException("Simulated error for AI Observer demo");
    }
}
