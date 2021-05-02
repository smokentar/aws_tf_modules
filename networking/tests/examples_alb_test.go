package test

import (
  "github.com/gruntwork-io/terratest/modules/terraform"
  http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
  "fmt"
  "testing"
  "time"
)

func TestAlbExample (t *testing.T) {

  terraformOptions := &terraform.Options {
    TerraformDir: "../examples/alb",

    // Variables to pass to the TF code using -var options
    Vars: map[string]interface{} {
      "alb_name": fmt.Sprintf("test-%s", uniqueId),
  }

  // Ensure env is destroyed post test run
  defer terraform.Destroy (t, terraformOptions)

  // Deploy the example
  terraform.Init(t, terraformOptions)
  terraform.Apply(t, terraformOptions)

  validateAlbExample (t, terraformOptions)
}

func validateAlbExample (t *testing.T, terraformOptions *terraform.Options) {
  // Run terraform output to fetch the output variables
  alb_dns_name := terraform.Output(t, terraformOptions, "alb_dns_name")
  alb_dns_name = fmt.Sprintf("http://%s", alb_dns_name)

  expectedStatus := 404
  expectedBody := "Unlucky mate"

  maxRetries := 10
  timeBetweenRetries := 10 * time.Second

  http_helper.HttpGetWithRetry (
    t,
    alb_dns_name,
    nil,
    expectedStatus,
    expectedBody,
    maxRetries,
    timeBetweenRetries,
  )
}
