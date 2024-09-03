package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"os/user"
	"strings"

	"github.com/joho/godotenv"
	"github.com/spf13/viper"
)

func BoEnvFileJwt() string {
	viper.SetConfigName(".bo.env")
	viper.SetConfigType("env")
	viper.AddConfigPath("$HOME/")
	viperErr := viper.ReadInConfig()
	if viperErr != nil {
		log.Fatal("Viper could not read file. Please verify: ", viperErr)
	}
	localJwtViperVar := viper.GetString("jwtBoEnvVar")
	if localJwtViperVar == "" {
		log.Fatal("No local jwt token found. Please use getToken (gt) to obtain a jwt.")
	}
	return localJwtViperVar
}

type apiCallStruct struct {
	body       string
	request    *http.Request
	status     string
	statusCode int
	method     string
	url        *url.URL
}

func ApiCall(boUrl string, boJwt string, method string, payload string) apiCallStruct {
	url := boUrl
	payloadReader := strings.NewReader(payload)

	client := &http.Client{}
	req, err := http.NewRequest(method, url, payloadReader)

	if err != nil {
		fmt.Println(err)
	}
	req.Header.Add("Content-Type", "application/json")
	req.Header.Add("Authorization", boJwt)

	res, err := client.Do(req)
	if err != nil {
		fmt.Println(err)

	}
	defer res.Body.Close()

	resBody, _ := io.ReadAll(res.Body)
	resStruct := apiCallStruct{
		body:       string(resBody),
		request:    res.Request,
		status:     res.Status,
		statusCode: res.StatusCode,
		method:     res.Request.Method,
		url:        res.Request.URL,
	}

	return resStruct
}

// Create ordered struct to be converted to string as payload with variables needed from account type.
type PayloadBase struct {
	tenantId string
}

func NewPayload(tenantIdField string) PayloadBase {
	payloadBaseObject := PayloadBase{}
	payloadBaseObject.tenantId = tenantIdField
	return payloadBaseObject
}

func previousCode() {
	itemJson := `{"myJson": "theJsonItem"}`
	var opJsonMap map[string]interface{}
	opErr := json.Unmarshal([]byte(itemJson), &opJsonMap)
	if opErr != nil {
		log.Fatal(opErr)
	}

	var opValue map[string]interface{}
	opValueErr := json.Unmarshal([]byte(opJsonMap["value"].(string)), &opValue)
	if opValueErr != nil {
		log.Fatal(opValueErr)
	}

	url := "url"
	method := "POST"

	// Build json from extracted clientId and secret
	payload := map[string]string{
		"clientId": opValue["clientId"].(string),
		"secret":   opValue["secret"].(string),
	}
	payloadString, _ := json.Marshal(payload)

	client := &http.Client{}
	req, err := http.NewRequest(method, url, bytes.NewReader(payloadString))

	if err != nil {
		fmt.Println(err)
		return
	}
	req.Header.Add("Content-Type", "application/json")

	res, err := client.Do(req)
	if err != nil {
		fmt.Println(err)
		return
	}
	defer res.Body.Close()

	// Read body and return full json from backoffice api login call
	// TODO uncomment
	//         jsonLoginResp, err := io.ReadAll(res.Body)
	body, err := io.ReadAll(res.Body)
	if err != nil {
		fmt.Println(err)
		return
	}

	// fmt.Println(string(body))
	jsonLoginResp := string(body)

	// Create struct for access to jwt value
	type jwtJson struct {
		JWT          string `json:"jwt"`
		RefreshToken string `json:"refreshToken"`
		ExpiresIn    int    `json:"expiresIn"`
		Expires      string `json:"expires"`
	}

	// Instantiate struct variable
	var jwtTokenJson jwtJson
	// More complex json unmarshal can be found at: https://www.golinuxcloud.com/golang-json-unmarshal/
	err = json.Unmarshal([]byte(jsonLoginResp), &jwtTokenJson)
	if err != nil {
		panic(err)
	}

	// Once json is unmarshalled, set and access jwtToken value
	jwtToken := jwtTokenJson.JWT
	// Set jwtToken environment variable in file for other commands to leverage
	mapJwt := map[string]string{
		"jwtBoEnvVar": jwtToken,
	}

	// Get machine current home directory at ~/ and use that for creating .bo.env file
	userCurrent, userCurrentErr := user.Current()
	if userCurrentErr != nil {
		log.Fatal(userCurrentErr.Error())
	}
	homeDir := userCurrent.HomeDir
	homeDir += "/.bo.env"
	viper.SetConfigFile(homeDir)
	viper.BindEnv("jwtBoEnvVar", jwtToken)
	envErr := godotenv.Write(mapJwt, homeDir)
	if envErr != nil {
		log.Fatal("Unable to write to file: '~/.bo.env'. Please check permissions.")
	}

	fmt.Println("getToken successfully called")
	fmt.Println("Token: \n", jwtToken)
}
