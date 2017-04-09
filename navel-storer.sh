#!/usr/bin/env bash

# Copyright (C) 2015-2017 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-installation-scripts is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> set

DIRNAME='dirname'
READLINK='readlink'

#-> set (avoid changing these variables)

dirname=$("${DIRNAME}" $0)
full_dirname=$("${READLINK}" -f ${dirname})

. "${full_dirname}/lib/navel-installer" || exit 1

program_name='navel-storer'

#-> functions

# usage

f_usage() {
    "${ECHO}" 'Usage:'
    "${ECHO}" -e "    ${0} [<options>] <git-branch>\n"
    "${ECHO}" 'Options:'
    "${ECHO}" "    [-d <DATABASE>]"
    "${ECHO}" -e "        ArangoDB DATABASE which heberge the foxx service\n"
    "${ECHO}" "    [-e <ENDPOINT>]"
    "${ECHO}" -e "        ArangoDB ENDPOINT to connect to\n"
    "${ECHO}" "    [-u <USERNAME>]"
    "${ECHO}" -e "        USERNAME to use if authentication is enabled\n"
    "${ECHO}" "    [-p <PASSWORD>]"
    "${ECHO}" -e "        PASSWORD to use if authentication is enabled\n"
    "${ECHO}" '    [-l]'
    "${ECHO}" -e "        Return the list of supported operating systems\n"

    exit $1
}

# define

f_global_define() {
    # set

    if [[ -n "${override_arangodb_database}" ]] ; then
        arangodb_database="${override_arangodb_database}"
    else
        arangodb_database='navel'
    fi

    arangodb_environment_options=()

    [[ -n "${arangodb_endpoint}" ]] && arangodb_environment_options+=(
        '--server.endpoint'
        "${arangodb_endpoint}"
    )

    arangodb_environment_options+=(
        '--server.authentication'
        'false'
    )

    if [[ -n "${arangodb_user}" ]] ; then
        arangodb_environment_options[-1]='true'

        arangodb_environment_options+=(
            '--server.username'
            "${arangodb_user}"
            '--server.password'
            "${arangodb_password}"
        )
    fi

    arangodb_foxx_service_source_package_url="${navel_git_remote_url}/${program_name}/archive/${navel_git_remote_branch}.zip"
    arangodb_foxx_service_mount="/${program_name}"

    # installation steps

    f_install_step_1() {
        f_pending "Ensuring existence of the ArangoDB database named ${arangodb_database}."

        w_arango_ensure_nonsystem_database "${arangodb_database}" "${arangodb_environment_options[@]}"
    }

    f_install_step_2() {
        f_pending "Installing ArangoDB Foxx service ${program_name} from ${arangodb_foxx_service_source_package_url} on ${arangodb_foxx_service_mount}."

        "${FOXXMANAGER}" "${arangodb_environment_options[@]}" \
            --server.database="${arangodb_database}" \
            replace "${arangodb_foxx_service_source_package_url}" "${arangodb_foxx_service_mount}"
    }
}

#-> check opts

while getopts 'd:e:u:p:l' OPT 2>/dev/null ; do
    case "${OPT}" in
        # t)
            # git_tag=${OPTARG} ;;
        d)
            override_arangodb_database="${OPTARG}" ;;
        e)
            arangodb_endpoint="${OPTARG}" ;;
        u)
            arangodb_user="${OPTARG}" ;;
        p)
            arangodb_password="${OPTARG}" ;;
        l)
            "${ECHO}" '*'

            exit 0

            ;;
        *)
            f_usage 1 ;;
    esac
done

navel_git_remote_branch="${@: -1}"

[[ -z "${navel_git_remote_branch}" ]] && f_usage 1

#-> start install

f_start_install '*'

#-> END
