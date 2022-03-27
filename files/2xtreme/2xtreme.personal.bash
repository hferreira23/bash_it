function __powerline_scm_prompt() {
	local color=""
	local scm_prompt=""

	scm_prompt_vars

	if [[ "${SCM_NONE_CHAR}" != "${SCM_CHAR}" ]]; then
		if [[ "${SCM_DIRTY}" -eq 3 ]]; then
			color=${SCM_THEME_PROMPT_STAGED_COLOR}
		elif [[ "${SCM_DIRTY}" -eq 2 ]]; then
			color=${SCM_THEME_PROMPT_UNSTAGED_COLOR}
		elif [[ "${SCM_DIRTY}" -eq 1 ]]; then
			color=${SCM_THEME_PROMPT_DIRTY_COLOR}
		else
			color=${SCM_THEME_PROMPT_CLEAN_COLOR}
		fi
		if [[ "${SCM_GIT_CHAR}" == "${SCM_CHAR}" ]]; then
			scm_prompt+="${SCM_CHAR}${SCM_BRANCH}${SCM_STATE}"
		elif [[ "${SCM_P4_CHAR}" == "${SCM_CHAR}" ]]; then
			scm_prompt+="${SCM_CHAR}${SCM_BRANCH}${SCM_STATE}"
		elif [[ "${SCM_HG_CHAR}" == "${SCM_CHAR}" ]]; then
			scm_prompt+="${SCM_CHAR}${SCM_BRANCH}${SCM_STATE}"
		elif [[ "${SCM_SVN_CHAR}" == "${SCM_CHAR}" ]]; then
			scm_prompt+="${SCM_CHAR}${SCM_BRANCH}${SCM_STATE}"
		fi
    echo "$(eval "echo ${scm_prompt}")|${color}"
	fi
}

function __powerline_battery_prompt() {
  local color="" battery_status
  if [[ -n $(uname -a | grep -i linux) ]]; then
    battery_status="$(battery_percentage 2> /dev/null)"
  else
    battery_status_macos="$(pmset -g batt | grep % | awk '{print $3}' | cut -d '%' -f 1 2> /dev/null)"
    battery_ac_macos="$(pmset -g batt | grep 'discharging' 2> /dev/null)"
  fi

  if [[ -z "${battery_status_macos}" || "${battery_status_macos}" == "-1" || "${battery_status_macos}" == "no" ]]; then
    true
  else
    if [[ "${battery_status_macos}" -le 15 ]]; then
      color="${BATTERY_STATUS_THEME_PROMPT_CRITICAL_COLOR}"
    elif [[ "${battery_status_macos}" -le 35 ]]; then
      color="${BATTERY_STATUS_THEME_PROMPT_LOW_COLOR}"
    else
      color="${BATTERY_STATUS_THEME_PROMPT_GOOD_COLOR}"
    fi
    if [[ -z ${battery_ac_macos} ]]; then
      battery_status_macos="${BATTERY_AC_CHAR}${battery_status_macos}"
    fi
    echo "$(eval "echo ${battery_status_macos}")%|${color}"
  fi

	if [[ -z "${battery_status}" || "${battery_status}" == "-1" || "${battery_status}" == "no" ]]; then
		true
	else
		if [[ "$((10#${battery_status}))" -le 15 ]]; then
			color="${BATTERY_STATUS_THEME_PROMPT_CRITICAL_COLOR}"
		elif [[ "$((10#${battery_status}))" -le 35 ]]; then
			color="${BATTERY_STATUS_THEME_PROMPT_LOW_COLOR}"
		else
			color="${BATTERY_STATUS_THEME_PROMPT_GOOD_COLOR}"
		fi
		ac_adapter_connected && battery_status="${BATTERY_AC_CHAR}${battery_status}"
    echo "$(eval "echo ${battery_status}")%|${color}"
	fi
}

function __powerline_os_prompt() {
  os_apple="$(uname -a | grep -i darwin)"
  os_linux="$(uname -a | grep -i linux)"
  os_wsl="$(uname -a | grep microsoft)"

  if [[ -n "${os_apple}" ]]; then
    echo "${OS_APPLE_CHAR}|${OS_THEME_PROMPT_COLOR}"
  elif [[ -n "${os_wsl}" ]]; then
    echo "${OS_WSL_CHAR}|${OS_THEME_PROMPT_COLOR}"
  elif [[ -n "${os_linux}" ]]; then
    echo "${OS_LINUX_CHAR}|${OS_THEME_PROMPT_COLOR}"
  fi
}
