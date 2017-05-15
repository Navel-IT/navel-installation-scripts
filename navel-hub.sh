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

program_name='navel-hub'

supported_os=(
    'rhel6'
    'rhel7'
    'debian7'
    'debian8'
)

#-> functions

# usage

f_usage() {
    "${ECHO}" 'Usage:'
    "${ECHO}" -e "    ${0} [<options>] <git-branch>\n"
    "${ECHO}" 'Options:'
    "${ECHO}" "    [-x <DIRECTORY>]"
    "${ECHO}" -e "        ${program_name} installation DIRECTORY\n"
    "${ECHO}" '    [-1]'
    "${ECHO}" -e "        Don't try to install ${cpanminus_module}\n"
    "${ECHO}" '    [-l]'
    "${ECHO}" -e "        Return the list of supported operating systems\n"

    exit $1
}

# define

f_global_define() {
    # set

    mandatory_pkg_to_install_via_pkg_manager=(
        'curl'
        'gcc'
        'libxml2'
        'tar'
    )

    source_package_url="${navel_git_remote_url}/${program_name}/archive/${navel_git_remote_branch}.tar.gz"

    if [[ -n "${override_program_install_directory}" ]] ; then
        program_install_directory="${override_program_install_directory}"
    else
        program_install_directory="/opt/${program_name}/"
    fi

    # installation steps

    f_install_step_1() {
        f_pending "Installing packages ${mandatory_pkg_to_install_via_pkg_manager[@]}."

        w_install_pkg "${mandatory_pkg_to_install_via_pkg_manager[@]}"
    }

    f_install_step_2() {
        f_pending "Installing ${cpanminus_module} via ${CURL}."

        "${CURL}" -L "${cpanminus_url}" | "${PERL}" - "${cpanminus_module}"
    }

    f_install_step_3() {
        f_pending "Creating directory ${program_install_directory}."

        w_mkdir "${program_install_directory}"
    }

    f_install_step_4() {
        f_pending "Downloading ${source_package_url} in ${program_install_directory}."

        "${CURL}" -L "${source_package_url}" | "${TAR}" xvzf - -C "${program_install_directory}" && "${MV}" "${program_name}-${navel_git_remote_branch}" $("${BASENAME}" "${program_install_directory}")
    }

    f_install_step_5() {
        f_pending "Installing ${program_name} dependencies."

        pushd "${program_install_directory}" && "${CPANM}" --installdeps . && popd
    }
}

#-> check opts

while getopts 'x:123l' OPT 2>/dev/null ; do
    case "${OPT}" in
        # t)
            # git_tag=${OPTARG} ;;
        x)
            override_program_install_directory="${OPTARG}" ;;
        1)
            disable_install_step[2]=1 ;;
        l)
            "${PRINTF}" '%s\n' "${supported_os[@]}"

            exit 0

            ;;
        *)
            f_usage 1 ;;
    esac
done

navel_git_remote_branch="${@: -1}"

[[ -z "${navel_git_remote_branch}" ]] && f_usage 1

#-> start install

f_start_install

#-> END

