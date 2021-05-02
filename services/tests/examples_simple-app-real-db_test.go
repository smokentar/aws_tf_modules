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

const dbDir = "../examples/mysql"
const appDir = "../examples/simple-app-real-db"

func TestSimpleAppRealDbExample(t *testing.T) {

  // Deploy the MySQL DB
  dbOptions := createDbOptions(t, dbDir)
  defer terraform.Destroy(t, dbOptions)
  terraform.Init(t, dbOptions)
  terraform.Apply(t, dbOptions)

  // Deploy the simple-app
  appOptions := createAppOptions(dbOptions, appDir)
  defer terraform.Destroy(t, appOptions)
  terraform.Init(t, appOptions)
  terraform.Apply(t, appOptions)

  // Validate the two modules integrate successfully
  validateSimpleAppRealDbExample(t, appOptions)
}

func createDbOptions(t *testing.T, terraformDir string) *terraformOptions {
  uniqueId := random.UniqueId()

  bucketForTesting := "temp-automated-testing-bucket"
  bucketRegionForTesting := "us-east-1"
  dbStateKey := fmt.Sprintf("%s/%s/terraform.tfstate", t.Name(), uniqueId)

  return &terraform.Options {
    TerraformDir: terraformDir,

    Vars: map[string]interface{}{
      "db_username": fmt.Sprintf("test%s", uniqueId),
      "db_password": fmt.Sprintf("password%s", uniqueId),
    },

    BackendConfig: map[string]interface{}{
      "bucket": bucketForTesting,
      "region": bucketRegionForTesting,
      "key": dbStateKey,
      "encrypt": true,
    },
  }
}

func createAppOptions(dbOptions *terraform.Options, terraformDir string) *TerraformOptions {
  return &terraform.Options {
    TerraformDir: terraformDir,

    Vars: map[string]interface{} {
      "db_remote_state_bucket": dbOptions.BackendConfig["bucket"],
      "db_remote_state_key": dbOptions.BackendConfig["key"],
    },
  }
}

func validateSimpleAppRealDbExample(t *testing.T, appOptions *terraform.Options) {
  // Run terraform output to fetch the output variables
  alb_dns_name := terraform.Output(t, terraformOptions, "alb_dns_name")
  alb_dns_name = fmt.Sprintf("http://%s", alb_dns_name)

  maxRetries := 10
  timeBetweenRetries := 10 * time.Second

  http_helper.HttpGetWithRetryWithCustomValidation(
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
