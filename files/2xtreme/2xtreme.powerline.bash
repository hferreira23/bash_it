# shellcheck shell=bash
# shellcheck disable=SC2034 # Expected behavior for themes.

# Define this here so it can be used by all of the Powerline themes
THEME_CHECK_SUDO=${THEME_CHECK_SUDO:=true}

function set_color() {
	local fg='' bg=''
	if [[ "${1:-}" != "-" ]]; then
		fg="38;5;${1}"
	fi
	if [[ "${2:-}" != "-" ]]; then
		bg="48;5;${2}"
		[[ -n "${fg}" ]] && bg=";${bg}"
	fi
	echo -e "\[\033[${fg}${bg}m\]"
}

function __powerline_user_info_prompt() {
	local user_info=""
	local color=${USER_INFO_THEME_PROMPT_COLOR}

	if [[ "${THEME_CHECK_SUDO}" = true ]]; then
		sudo -vn 1> /dev/null 2>&1 && color=${USER_INFO_THEME_PROMPT_COLOR_SUDO}
	fi

	case "${POWERLINE_PROMPT_USER_INFO_MODE}" in
		"sudo")
			if [[ "${color}" = "${USER_INFO_THEME_PROMPT_COLOR_SUDO}" ]]; then
				user_info="!"
			fi
			;;
		*)
			local user=${SHORT_USER:-${USER}}
			if [[ -n "${SSH_CLIENT}" ]] || [[ -n "${SSH_CONNECTION}" ]]; then
				user_info="${USER_INFO_SSH_CHAR}${user}"
			else
				user_info="${user}"
			fi
			;;
	esac
	[[ -n "${user_info}" ]] && echo "${user_info}|${color}"
}

function __powerline_terraform_prompt() {
	local terraform_workspace=""

	if [ -f *.tf ]; then
		terraform_workspace="$(terraform_workspace_prompt)"
		[[ -n "${terraform_workspace}" ]] && echo "${TERRAFORM_CHAR}${terraform_workspace}|${TERRAFORM_THEME_PROMPT_COLOR}"
	fi
}

function __powerline_gcloud_prompt() {
	local active_gcloud_account=""

	active_gcloud_account="$(active_gcloud_account_prompt)"
	[[ -n "${active_gcloud_account}" ]] && echo "${GCLOUD_CHAR}${active_gcloud_account}|${GCLOUD_THEME_PROMPT_COLOR}"
}

function __powerline_node_prompt() {
	local node_version=""

	node_version="$(node_version_prompt)"
	[[ -n "${node_version}" ]] && echo "${NODE_CHAR}${node_version}|${NODE_THEME_PROMPT_COLOR}"
}

function __powerline_ruby_prompt() {
	local ruby_version=""

	if _command_exists rvm; then
		ruby_version="$(rvm_version_prompt)"
	elif _command_exists rbenv; then
		ruby_version=$(rbenv_version_prompt)
	fi

	[[ -n "${ruby_version}" ]] && echo "${RUBY_CHAR}${ruby_version}|${RUBY_THEME_PROMPT_COLOR}"
}

function __powerline_k8s_context_prompt() {
	local kubernetes_context=""

	if _command_exists kubectl; then
		kubernetes_context="$(k8s_context_prompt)"
	fi

	[[ -n "${kubernetes_context}" ]] && echo "${KUBERNETES_CONTEXT_THEME_CHAR}${kubernetes_context}|${KUBERNETES_CONTEXT_THEME_PROMPT_COLOR}"
}

function __powerline_k8s_namespace_prompt() {
	local kubernetes_namespace=""

	if _command_exists kubectl; then
		kubernetes_namespace="$(k8s_namespace_prompt)"
	fi

	[[ -n "${kubernetes_namespace}" ]] && echo "${KUBERNETES_NAMESPACE_THEME_CHAR}${kubernetes_namespace}|${KUBERNETES_NAMESPACE_THEME_PROMPT_COLOR}"
}

function __powerline_python_venv_prompt() {
	local python_venv=""

	if [[ -n "${CONDA_DEFAULT_ENV:-}" ]]; then
		python_venv="${CONDA_DEFAULT_ENV}"
		PYTHON_VENV_CHAR=${CONDA_PYTHON_VENV_CHAR}
	elif [[ -n "${VIRTUAL_ENV:-}" ]]; then
		python_venv="${VIRTUAL_ENV##*/}"
	fi

	[[ -n "${python_venv}" ]] && echo "${PYTHON_VENV_CHAR}${python_venv}|${PYTHON_VENV_THEME_PROMPT_COLOR}"
}

function __powerline_cwd_prompt() {
	echo "\w|${CWD_THEME_PROMPT_COLOR}"
}

function __powerline_hostname_prompt() {
	echo "${SHORT_HOSTNAME:-$(hostname -s)}|${HOST_THEME_PROMPT_COLOR}"
}

function __powerline_wd_prompt() {
	echo "\W|${CWD_THEME_PROMPT_COLOR}"
}

function __powerline_clock_prompt() {
	echo "$(date +"${THEME_CLOCK_FORMAT}")|${CLOCK_THEME_PROMPT_COLOR}"
}

function __powerline_in_vim_prompt() {
	if [[ -n "$VIMRUNTIME" ]]; then
		echo "${IN_VIM_THEME_PROMPT_TEXT}|${IN_VIM_THEME_PROMPT_COLOR}"
	fi
}

function __powerline_aws_profile_prompt() {
	if [[ -n "${AWSUME_PROFILE}" ]]; then
		echo "${AWS_PROFILE_CHAR}${AWSUME_PROFILE}|${AWS_PROFILE_PROMPT_COLOR}"
	fi
}

function __powerline_in_toolbox_prompt() {
	if [ -f /run/.containerenv ] && [ -f /run/.toolboxenv ]; then
		echo "${IN_TOOLBOX_THEME_PROMPT_TEXT}|${IN_TOOLBOX_THEME_PROMPT_COLOR}"
	fi
}

function __powerline_shlvl_prompt() {
	if [[ "${SHLVL}" -gt 1 ]]; then
		local prompt="${SHLVL_THEME_PROMPT_CHAR}"
		local level=$((SHLVL - 1))
		echo "${prompt}${level}|${SHLVL_THEME_PROMPT_COLOR}"
	fi
}

function __powerline_dirstack_prompt() {
	if [[ "${#DIRSTACK[@]}" -gt 1 ]]; then
		local depth=$((${#DIRSTACK[@]} - 1))
		local prompt="${DIRSTACK_THEME_PROMPT_CHAR}"
		if [[ "${depth}" -ge 2 ]]; then
			prompt+="${depth}"
		fi
		echo "${prompt}|${DIRSTACK_THEME_PROMPT_COLOR}"
	fi
}

function __powerline_history_number_prompt() {
	echo "${HISTORY_NUMBER_THEME_PROMPT_CHAR}\!|${HISTORY_NUMBER_THEME_PROMPT_COLOR}"
}

function __powerline_command_number_prompt() {
	echo "${COMMAND_NUMBER_THEME_PROMPT_CHAR}\#|${COMMAND_NUMBER_THEME_PROMPT_COLOR}"
}

function __powerline_duration_prompt() {
	local duration
	duration=$(_command_duration)
	[[ -n "$duration" ]] && echo "${duration}|${COMMAND_DURATION_PROMPT_COLOR}"
}

function __powerline_left_segment() {
	local params
	IFS="|" read -ra params <<< "${1}"
	local pad_before_segment=" "

	if [[ "${SEGMENTS_AT_LEFT}" -eq 0 ]]; then
		if [[ "${POWERLINE_COMPACT_BEFORE_FIRST_SEGMENT}" -ne 0 ]]; then
			pad_before_segment=""
		fi
	else
		if [[ "${POWERLINE_COMPACT_AFTER_SEPARATOR}" -ne 0 ]]; then
			pad_before_segment=""
		fi
		# Since the previous segment wasn't the last segment, add padding, if needed
		#
		if [[ "${POWERLINE_COMPACT_BEFORE_SEPARATOR}" -eq 0 ]]; then
			LEFT_PROMPT+="$(set_color - "${LAST_SEGMENT_COLOR}") ${normal?}"
		fi
		if [[ "${LAST_SEGMENT_COLOR}" -eq "${params[1]}" ]]; then
			LEFT_PROMPT+="$(set_color - "${LAST_SEGMENT_COLOR}")${POWERLINE_LEFT_SEPARATOR_SOFT}${normal?}"
		else
			LEFT_PROMPT+="$(set_color "${LAST_SEGMENT_COLOR}" "${params[1]}")${POWERLINE_LEFT_SEPARATOR}${normal?}"
		fi
	fi

	LEFT_PROMPT+="$(set_color - "${params[1]}")${pad_before_segment}${params[0]}${normal}"
	LAST_SEGMENT_COLOR=${params[1]}
	((SEGMENTS_AT_LEFT += 1))
}

function __powerline_left_last_segment_padding() {
	LEFT_PROMPT+="$(set_color - "${LAST_SEGMENT_COLOR}") ${normal?}"
}

function __powerline_last_status_prompt() {
	[[ "$1" -ne 0 ]] && echo "${1}|${LAST_STATUS_THEME_PROMPT_COLOR}"
}
