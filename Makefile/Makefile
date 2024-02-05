# Makefile to clone a Git repository

# Git repository URL
REPO_URL = https://github.com/Manisha-Bayya/simple-django-project.git

# Target directory for cloning
TARGET_DIR = repo_directory

# Default rule
all: clone

# Rule to clone the Git repository
clone:
	git clone $(REPO_URL) $(TARGET_DIR)

# Clean rule
clean:
	rmdir /s /q $(TARGET_DIR)
