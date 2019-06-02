package main

import (
	"context"
	"fmt"
	"github.com/google/go-github/github"
	"golang.org/x/oauth2"
	"os"
	"strings"
	"time"
)

var (
	github_token = os.Getenv("GITHUB_TOKEN")
	labels       = []string{os.Getenv("LABEL")}
	owner        = os.Getenv("OWNER")
	issue_repos  = os.Getenv("ISSUE_REPOS")
	pr_repos     = os.Getenv("PR_REPOS")
	since, err   = time.Parse("2006-01-02", os.Getenv("SINCE"))
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

	issue_repos_slice := strings.Split(issue_repos, " ")

	options := &github.IssueListByRepoOptions{
		Since:  since,
		Labels: labels,
		ListOptions: github.ListOptions{
			Page:    1,
			PerPage: 100,
		},
	}

	for _, repo := range issue_repos_slice {
		fmt.Println(repo)
		issues, _, err := client.Issues.ListByRepo(ctx, owner, repo, options)

		if err != nil {
			fmt.Printf("Error: %v\n", err)
			return
		}

		for i, issue := range issues {
			fmt.Printf("%v, %v, %v\n", i, *issue.Title, *issue.URL, *issue.UpdatedAt)
		}
	}
}
