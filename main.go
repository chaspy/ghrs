package main

import (
	"context"
	"fmt"
	"os"
	"github.com/google/go-github/github"
	"golang.org/x/oauth2"
)

func FetchOrganizations(username string) ([]*github.Organization, error) {
	client := github.NewClient(nil)
	orgs, _, err := client.Organizations.List(context.Background(), username, nil)
	return orgs, err
}

func main() {
	var username string
	fmt.Print("Enter GitHub username: ")
	fmt.Scanf("%s", &username)

	ctx := context.Background()
	ts := oauth2.StaticTokenSource(
		&oauth2.Token{AccessToken: os.Getenv("GITHUB_TOKEN")},
	)
	tc := oauth2.NewClient(ctx, ts)

	client := github.NewClient(tc)

	// list all repositories for the authenticated user
	repos, _, err := client.Repositories.List(ctx, "", nil)

	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}

	for i, repo := range repos {
		fmt.Printf("%#v. %+v\n", i+1, repo.GetURL())
	}
}
