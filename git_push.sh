#!/bin/bash

# Налаштування
BRANCH="main"              # або "master", якщо твоя гілка називається інакше
COMMIT_MSG="auto commit"   # або змінюй як аргумент скрипта

# Вихід при помилках
set -e

# Додати всі зміни
git add .

# Зробити коміт з повідомленням (можна передавати як аргумент)
if [ -n "$1" ]; then
  COMMIT_MSG="$1"
fi

git commit -m "$COMMIT_MSG"

# Пуш до GitHub
git push
