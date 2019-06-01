package main

import (
	"context"
	"fmt"
	"os"
	"github.com/google/go-github/github"
	"golang.org/x/oauth2"
)

var (
	github_token = os.Getenv("GITHUB_TOKEN")
	label        = os.Getenv("LABEL")
	owner        = os.Getenv("OWNER")
	issue_repos  = os.Getenv("ISSUE_REPOS")
	pr_repos     = os.Getenv("PR_REPOS")
	since        = os.Getenv("SINCE")
	members      = os.Getenv("MEMBERS")
	result       = os.Getenv("RESULT")
	except_word  = os.Getenv("EXCEPT_WORD")
)

func main() {
	ctx := context.Background()
	ts := oauth2.StaticTokenSource(
		&oauth2.Token{AccessToken: github_token},
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
