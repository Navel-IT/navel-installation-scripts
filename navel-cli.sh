#!/usr/bin/env bash

# Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-installation-scripts is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> set

DIRNAME='dirname'
READLINK='readlink'

#-> where am i ?

dirname=$(${DIRNAME} $0)
full_dirname=$(${READLINK} -f ${dirname})

#-> set (avoid changing these variables)

. "${full_dirname}/lib/navel-installer" || exit 1

program_name='navel-cli'

#-> functions

# usage

f_usage() {
    "${ECHO}" 'Usage:'
    "${ECHO}" -e "    ${0} [<options>] [<git-branch> (default to ${navel_git_remote_branch}]\n"
    "${ECHO}" 'Options:'
    "${ECHO}" '    [-1]'
    "${ECHO}" -e "        Don't try to install ${cpanminus_module}\n"
    "${ECHO}" '    [-l]'
    "${ECHO}" -e "        Return the list of supported operating systems\n"

    exit $1
}

# define

_f_define() {
    # set

    mandatory_pkg_to_install_via_pkg_manager=(
        'curl'
        'gcc'
        'libxml2'
    )

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
        local cpanm_navel_gitchain=$(f_build_cpanm_navel_gitchain 'navel-base' 'navel-api' 'navel-logger' $program_name)

        f_pending "Installing ${cpanm_navel_gitchain[@]}."

        "${CPANM}" "${cpanm_navel_gitchain[@]}"
    }
}

_f_define_for_rhel() {
    _f_define

    # set

    YUM='yum'
    CHKCONFIG='chkconfig'

    mandatory_pkg_to_install_via_pkg_manager+=(
        'libxml2-devel'
    )
}

_f_define_for_debian() {
    _f_define

    # set

    APT_GET='apt-get'
    UPDATE_RC_D='update-rc.d'

    mandatory_pkg_to_install_via_pkg_manager+=(
        'libxml2-dev'
    )
}

f_define_for_rhel6() {
    _f_define_for_rhel
}

f_define_for_rhel7() {
    _f_define_for_rhel
}

f_define_for_debian7() {
    _f_define_for_debian
}

f_define_for_debian8() {
    _f_define_for_debian
}

#-> check opts

while getopts '1l' OPT 2>/dev/null ; do
    case "${OPT}" in
        # t)
            # git_tag=${OPTARG} ;;
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
