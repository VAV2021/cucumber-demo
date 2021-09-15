Based on "10 Minute Tutorial" at Cucumber.io <https://cucumber.io/docs/guides/10-minute-tutorial/>

Preliminary:

- install Gradle and verify that `gradle` is on your command search path
- open a terminal or command window (Linux "shell")
- create an empty product directory and chdir (`cd`) to the directory

Steps

1. Run `gradle init`. Choose:
   * 2: application
   * 3: Java
   * 1: no - only one application project
   * 1: Groovy DSL
   * 1: JUnit 4
   * Project name: cucumber-demo (or whatever your directory name is)
   * Source package: **demo**

2. Squash the "app" dir for simplicity. (Old versions of Gradle don't do this.)
   * move everything in "app" to the project dir: `mv app/* .`
   * remove the "app" dir: `rmdir app`
   * edit `settings.gradle` and delete the line `include('app')`

3. Edit `build.gradle`.  Add cucumber dependencies.    
   These are from the Cucumber tutorial on Smartbear (reference below). JUnit is not really required to run Cucumber.
   ```
   dependencies {
       // Use JUnit test framework.
       testImplementation 'junit:junit:4.13'
       ...

       // Cucumber
       testImplementation 'io.cucumber:cucumber-java:6.10.4'
       testImplementation 'io.cucumber:cucumber-junit:6.10.4'
   }
   ```

4. Also in `build.gradle` add cucumber task and configuration (I put these at the bottom of the file).
   ```
   configurations {
       cucumberRuntime {
           extendsFrom testImplementation
       }
   }

   task cucumber() {
       dependsOn assemble, testClasses
       doLast {
           javaexec {
               main = "io.cucumber.core.cli.Main"
               classpath = configurations.cucumberRuntime + sourceSets.main.output + sourceSets.test.output
               args = ['--plugin', 'pretty', '--glue', 'demo', 'src/test/resources']
               // args = ['--snippets', 'camelcase', '--plugin', 'pretty', '--glue', 'demo', 'src/test/resources']
           }
       }
   }
   ```

6. Verify that you have this directory: `src/test/resources`.  That directory is refereed to in the `javaexec` line above.
   - TODO  Explain what the javaexec command means

7. Run `gradle cucumber`.  It should succeed.
   * Windows Users: **Does the output show control characters?**
   * Cucumber uses a lot of color. To show color in a terminal window it uses special character sequence. On some Windows version, the Command prompt does not process those control sequences so the output is unreadable.  There are 2 solutions:
     1. Use the Git/Bash shell or any Bash for windows (MinGW).
     2. In the `args` list of the `cucumber` task, add a `-m` argument.  `-m` means monochrome.

8. (Optional) To get rid of the verbose output about sharing code, create a file `src/test/resources/cucumber.properties` containing these lines:
   ```
   cucumber.publish.quiet=true
   # for Java, use camelcase method names in snippet code
   #cucumber.snippet-type=camelcase
   ```

9. Create a feature file in src/test/resources/features (I think any directory inside of "resources" can be used. It does not need to match the package where your code will be.)
   ```
   deposit_money.feature
   ```

10. Put a feature and some scenarios in the feature file.
   * The feature code is listed below.

11. Run `gradle cucumber` again.  Notice the messages and the suggested "glue" code.

12. The "glue" code is using snake case (like Python). We want CamelCase, so edit build.gradle and add the option "--snippets camelcase" or uncomment this option in `cucumber.properties`.  But you have to add these as separate arguments in a list.

13. Run `gradle cucumber` again.

14. Create a glue file (a Java class) in src/test/java/demo/
    - Be sure to use the correct package name (`demo`).
    - See example glue file below.

15. Run `gradle cucumber` again.
    - This time is should "match" the **Steps** in your feature file with Glue code using the annotation.
    - But, the code throws a `PendingException`, which means that you did not write any useful glue code yet.

16. In the glue code `DepositTest.java` replace the PendingException lines with some System.out.println() commands.
15. 

## Structure of your Project

Now you should have a project structure like this:
```
build.gradle
gradle/
gradlew
README.md
settings.gradle
src/
    main/java/
              demo/
    test/resources/
              cucumber.properties
              features/
                 deposit_money.feature
                 (your feature files go here)
        /java/demo/
                 (your "glue" code will go here)
```

> **You Don't Need Gradle or Maven**
>
> You can use Cucumber in any Java project.  It is instructive to use the CLI only.
> However, you need to install the correct JAR files for Cucumber, Gherkin, 
> and their dependencies, and setup a CLASSPATH for this project.

---

### Feature Files

`deposit_money.feature`
```gherkin
Feature: Make deposits to a bank account
  A customer can deposit to a bank account and his balance is updated.

  Scenario: open a new account
    Given I open a bank account
    Then The balance is 0

  Scenario: deposit to an account
    Given I open a bank account
    When I deposit 100
    Then The balance is 100
```

Later (really! don't add this the first time) add:
```gherkin
  Scenario: make several deposits to an account
    Given I open a bank account
    When I deposit 100
     And I deposit 30
     And I deposit 25
    Then The balance is 155
```


### Glue Code

**Where to put the glue code?**  Your Glue Code files can have **any name**, but they should be in a package that cucumber is configured to look in.  In `build.gradle` we wrote that this package is "demo" (the `--glue` argument).

Many Cucumber tutorials create a file named `StepDefinitions.java`. IntelliJ uses this name, too.  This is not necessary.

Your glue code will always include the `@Given`, `@When`, `@Then` annotations and may use others, so you will need the following imports:
```java
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
```
"en" is for English language. You can use other languages, including Thai.

The snippets are suggested by Cucumber.  You can modify the snippets as you like.  This is one possible change.

```java
package demo;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;

public class BankingTest {
    @Given("I open a bank account")
    public void i_open_a_bank_account() {
        System.out.println("You opened a bank account.");
    }
    
    @Then("The balance is {int}")
    public void the_balance_is(Integer balance) {
        System.out.printf("Your balance is %d\n", balance);
    }
    
    @When("I deposit {int}")
    public void i_deposit(Integer amount) {
        System.out.printf("You deposited %d\n", amount);
    }
}
```

## Add More Scenarios

TODO

## Write Source Code for BankAccount and Test it!


### References

* Cucumber Home <https://cucumber.io>
* BDD: Automation Testing with Cucumber <https://www.bornfight.com/blog/behavior-driven-development-automation-testing-with-cucumber/>
* Cucumber 10 Minute Tutorial <https://cucumber.io/docs/guides/10-minute-tutorial/#make-it-pass> shows how to configure Gradle for cucumber.
