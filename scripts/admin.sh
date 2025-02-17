 #!/bin/zsh
function auth {
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  BLUE='\033[0;34m'
  NC='\033[0m' # No Color
  local working_dir="/home/tomasz/archipad"
  local main_dir="archipad-plus-ts"
  local type=$1 # epic, feature
  local num=$2
  local app=$3
  local target_dir="main"

  if [[ "$num" != "main" ]]; then
    local worktrees_path="${working_dir}/${main_dir}.worktrees"
    local base_path="${worktrees_path}/${type}"
    target_dir=$(ls -d "${base_path}/PLUS-${num}"*/ 2>/dev/null | head -n 1)


    echo "Starting auth in ${target_dir}"
    cd "${target_dir%/}"
   	if [[ -z "$app" ]]; then 
        npx nx run-many --target=serve --projects=auth-api,auth-ui
    fi
	if [[ "$app" == "api" ]]; then
            npx nx run auth-api:serve --configuration=development
	fi
	if [[ "$app" == "ui" ]]; then
	    npx nx run auth-ui:serve --configuration=local
	fi
    if [[ "$app" == "dir" ]]; then
    fi

  else
    echo "${BLUE}Bye!${NC}"
  fi
}

function admin {
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  BLUE='\033[0;34m'
  NC='\033[0m' # No Color
  local working_dir="/home/tomasz/archipad"
  local main_dir="archipad-plus-ts"
  local type=$1 # epic, feature
  local num=$2
  local app=$3
  local target_dir="main"
  if [[ "$num" != "main" ]]; then
    local worktrees_path="${working_dir}/${main_dir}.worktrees"
    local base_path="${worktrees_path}/${type}"
    target_dir=$(ls -d "${base_path}/PLUS-${num}"*/ 2>/dev/null | head -n 1)
  
    if [[ -z "$target_dir" ]]; then
      echo "${RED}No admin ${type} found starting with PLUS-${num}${NC}"
      # echo "Do you want to add a new worktree? (y/n)"
      # read -r response
      vared -p "Do you want to add a new worktree? (y/n)  " -c response
      if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        cd "${working_dir}/${main_dir}"

        echo "${GREEN}Fetching latest remote branches...${NC}"
        git fetch origin

        branches=($(git branch -r | grep -v '\->' | sed 's/^ *origin\///' | grep -v '^\s*$'))

        # Ensure 'main' is at the top
        branches_sorted=()
        for branch in "${branches[@]}"; do
          if [[ "$branch" == "main" ]]; then
            branches_sorted=("main" "${branches_sorted[@]}")
          else
            branches_sorted+=("$branch")
          fi
        done

        for ((i = 1; i <= ${#branches_sorted[@]}; i++)); do
          echo "$((i)). ${branches_sorted[$i]}"
        done

        echo "\nWhat branch do you want to start from?"
        vared -p "Enter the number of the branch you want to select:  " -c branch_number
        selected_branch=${branches_sorted[$((branch_number))]}
	if [[ -z "$selected_branch" ]]; then
	  echo "${RED}Wrong selection${NC}"
	  return;
	fi

        vared -p "Do you want to working on this branch directly? (y/n)  " -c response

        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
          echo "${GREEN}Adding new worktree for the selected branch${NC}"
	  
          workingtree_path="${worktrees_path}/${selected_branch}"
          git worktree add "${workingtree_path}" "${selected_branch}"
          cd "${workingtree_path}" 
          echo "${GREEN}Copy env variables from main${NC}"

          # cp "${working_dir}/${main_dir}/apps/admin-api/.env" "${workingtree_path}/apps/admin-api/"
          cp "${workingtree_path}/apps/admin-api/.env.example" "${workingtree_path}/apps/admin-api/.env"
          cp "${workingtree_path}/apps/auth-api/.env.example" "${workingtree_path}/apps/auth-api/.env"
          cp "${workingtree_path}/apps/auth-ui/.env.example" "${workingtree_path}/apps/auth-ui/.env"
          echo "${GREEN}Install dependencies${NC}"
          npm install
          target_dir="${workingtree_path}"
        else
          echo "${GREEN}Creating new ${type} branch based on ${BLUE}${selected_branch}${NC}..."
          vared -p "What is the ${type} number? (e.g. 425)  " -c num
          vared -p "What is the description of the new ${type} branch? (e.g. my-new-awesome-${type})  " -c feature_name

          new_branch="${type}/PLUS-${num}.${feature_name}"
          new_dir="${base_path}/PLUS-${num}.${feature_name}"

          echo "${GREEN}Create new branch and worktree${NC}"
          git worktree add "${new_dir}" -b "${new_branch}" "origin/${selected_branch}"

          if [[ $? -eq 0 ]]; then
            echo "${BLUE}Worktree for ${new_branch} created at ${new_dir}${NC}"
            cd "${new_dir}" && echo "Changed directory to: ${new_dir}"
            echo "${GREEN}Copy env variables from main${NC}"

            # cp "${working_dir}/${main_dir}/apps/admin-api/.env" "${new_dir}/apps/admin-api/.env"
            cp "${new_dir}/apps/admin-api/.env.example" "${new_dir}/apps/admin-api/.env"
            cp "${new_dir}/apps/auth-api/.env.example" "${new_dir}/apps/auth-api/.env"
            cp "${new_dir}/apps/auth-ui/.env.example" "${new_dir}/apps/auth-ui/.env"
            echo "${GREEN}Install dependencies${NC}"
            npm install
            git branch --unset-upstream
            target_dir=$new_dir
          else
            echo "${RED}Failed to create worktree for ${new_branch}${NC}"
          fi
        fi
      fi
    fi
  fi
  if [[ -n "$target_dir" ]]; then
    echo "Starting admin in ${target_dir}"
    if [[ "$target_dir" == "main" ]]; then
      cd "${working_dir}/${main_dir}"
    else
      cd "${target_dir%/}"
    fi
   	if [[ -z "$app" ]]; then 
        npx nx run-many --target=serve --projects=admin-api,admin-ui
    fi
	if [[ "$app" == "api" ]]; then
            npx nx run admin-api:serve --configuration=development
	fi
	if [[ "$app" == "ui" ]]; then
	    npx nx run admin-ui:serve --configuration=local
	fi
    if [[ "$app" == "dir" ]]; then
    fi

  else
    echo "${BLUE}Bye!${NC}"
  fi
}
