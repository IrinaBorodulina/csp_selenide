package org.example;

import com.codeborne.selenide.Configuration;
import io.github.bonigarcia.wdm.WebDriverManager;
import org.openqa.selenium.chrome.ChromeOptions;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import static com.codeborne.selenide.Condition.text;
import static com.codeborne.selenide.Selenide.$;
import static com.codeborne.selenide.Selenide.closeWebDriver;
import static com.codeborne.selenide.Selenide.open;

class ExampleDotOrgTest {

    @BeforeAll
    static void setUp() {
        String remoteUrl = System.getProperty("selenide.remote");
        String localChromeDriver = System.getProperty("webdriver.chrome.driver");

        if (remoteUrl == null || remoteUrl.trim().isEmpty()) {
            if (localChromeDriver == null || localChromeDriver.trim().isEmpty()) {
                WebDriverManager.chromedriver()
                        .browserVersion("114.0.5735.90")
                        .setup();
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
    }

    @AfterEach
    void tearDown() {
        closeWebDriver();
    }

    @Test
    void shouldOpenExampleDotOrg() {
        open("/");

        $("h1").shouldHave(text("Example Domain"));
    }
}
