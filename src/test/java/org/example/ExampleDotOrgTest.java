package org.example;

import com.codeborne.selenide.Configuration;
import io.github.bonigarcia.wdm.WebDriverManager;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.remote.CapabilityType;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import static com.codeborne.selenide.Condition.text;
import static com.codeborne.selenide.Selenide.$;
import static com.codeborne.selenide.Selenide.closeWebDriver;
import static com.codeborne.selenide.Selenide.open;

class ExampleDotOrgTest {

    private static final String CONTAINER_CHROMEDRIVER = "/usr/local/bin/chromedriver";

    @BeforeAll
    static void setUp() {
        String remoteUrl = System.getProperty("selenide.remote");
        String localChromeDriver = System.getProperty("webdriver.chrome.driver");
        String chromeBinary = System.getProperty("chrome.binary");

        if (remoteUrl == null || remoteUrl.trim().isEmpty()) {
            if (localChromeDriver == null || localChromeDriver.trim().isEmpty()) {
                if (new java.io.File(CONTAINER_CHROMEDRIVER).isFile()) {
                    System.setProperty("webdriver.chrome.driver", CONTAINER_CHROMEDRIVER);
                } else {
                    WebDriverManager.chromedriver().setup();
                }
            } else {
                System.setProperty("webdriver.chrome.driver", localChromeDriver);
            }

            if (System.getProperty("webdriver.chrome.driver") == null
                    || System.getProperty("webdriver.chrome.driver").trim().isEmpty()) {
                WebDriverManager.chromedriver().setup();
            }
            Configuration.browser = "chrome";
        } else {
            ChromeOptions options = new ChromeOptions();
            options.setBrowserVersion("114");

            Configuration.remote = remoteUrl;
            Configuration.browserCapabilities = options;
            Configuration.browser = "chrome";
        }

        Configuration.browserSize = "1920x1080";
        Configuration.headless = Boolean.parseBoolean(System.getProperty("headless", "false"));
        Configuration.baseUrl = "https://example.org";

        ChromeOptions options;
        if (chromeBinary != null && !chromeBinary.trim().isEmpty()) {
            options = new ChromeOptions();
            options.setBinary(chromeBinary);
            Configuration.browserCapabilities = options;
        } else if (Configuration.browserCapabilities == null) {
            options = new ChromeOptions();
            Configuration.browserCapabilities = options;
        } else {
            options = (ChromeOptions) Configuration.browserCapabilities;
        }

        options.addArguments("--no-sandbox");
        options.addArguments("--disable-dev-shm-usage");
        options.addArguments("--disable-gpu");
        options.addArguments("--remote-allow-origins=*");
        if (Configuration.headless) {
            // Chrome 114 in the Docker image is more stable with legacy headless mode.
            options.addArguments("--headless");
        }
        options.setCapability(CapabilityType.ACCEPT_INSECURE_CERTS, true);
    }

    @AfterEach
    void tearDown() {
        closeWebDriver();
    }

    @Test
    void shouldOpenExampleDotOrg() {
        open("/");

        $("body").shouldHave(text("Example Domain"));
    }
}
