package test

import (
  "github.com/gruntwork-io/terratest/modules/terraform"
  http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
  "github.com/gruntwork-io/terratest/modules/random"
  "fmt"
  "testing"
  "time"
  "strings"
)

func TestSimpleAppExample (t *testing.T) {

  // Unique ID passed to resource names to avoid parallel test clashing
  uniqueId := random.UniqueId()

  terraformOptions := &terraform.Options {
    TerraformDir: "../examples/simple-app",

    // Input varialbe passed to the alb example using -var options
    Vars: map[string]interface{} {
      "alb_name": fmt.Sprintf("test-%s", uniqueId),

      "mysql_config": map[string]interface{}{
        "endpoint": "test-db",
        "port": "9999",
      },
    },
  }

  // Ensure env is destroyed post test run
  defer terraform.Destroy (t, terraformOptions)

  // Deploy the example
  terraform.Init(t, terraformOptions)
  terraform.Apply(t, terraformOptions)

  validateSimpleAppExample (t, terraformOptions)
}

func validateSimpleAppExample (t *testing.T, terraformOptions *terraform.Options) {
  // Run terraform output to fetch the output variables
  alb_dns_name := terraform.Output(t, terraformOptions, "alb_dns_name")
  alb_dns_name = fmt.Sprintf("http://%s", alb_dns_name)

  maxRetries := 10
  timeBetweenRetries := 10 * time.Second

  http_helper.HttpGetWithRetryWithCustomValidation (
    t,
    alb_dns_name,
    nil,
    maxRetries,
    timeBetweenRetries,
    func (status int, body string) bool {
      return status == 200 &&
        strings.Contains(body, "Ubuntu")
    },
  )
}
