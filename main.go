package main

import (
	"context"
	"fmt"
	"os"
	"github.com/google/go-github/github"
	"golang.org/x/oauth2"
)

func main() {
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
