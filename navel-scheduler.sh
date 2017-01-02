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

program_name='navel-scheduler'

# disabled steps

disable_install_step[6]=1

disable_install_step[15]=1
disable_install_step[16]=1
disable_install_step[17]=1

#-> functions

# usage

f_usage() {
    "${ECHO}" 'Usage:'
    "${ECHO}" -e "    ${0} [<options>] <git-branch>\n"
    "${ECHO}" 'Options:'
    "${ECHO}" "    [-x <DIRECTORY>]"
    "${ECHO}" -e "        DIRECTORY of the ${program_name} binary\n"
    "${ECHO}" '    [-1]'
    "${ECHO}" -e "        Don't try to install ${cpanminus_module}\n"
    "${ECHO}" '    [-2]'
    "${ECHO}" -e "        Copy default configuration files\n"
    "${ECHO}" '    [-3]'
    "${ECHO}" -e "        Install logrotate and configure it for ${program_name} logs\n"
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

    configuration_directory='/usr/local/etc/'
    run_directory="/var/run/"
    log_directory="/var/log/"

    program_user='navel-scheduler'
    program_group='navel-scheduler'

    program_template_source_directory="${full_dirname}/template/${program_name}"

    program_home_directory="${configuration_directory}/${program_name}/"
    program_run_directory="${run_directory}/${program_name}/"
    program_log_directory="${log_directory}/${program_name}/"

    program_run_file="${program_run_directory}/${program_name}.pid"
    program_log_file="${program_log_directory}/${program_name}.log"

    program_binary_directory="/usr/local/bin/"

    program_configuration_source_directory="${program_template_source_directory}/configuration/"
    program_configuration_destination_directory="${program_home_directory}"

    program_service_source_directory="${program_template_source_directory}/service/"

    program_service_default_source_directory="${program_service_source_directory}/default/"
    program_service_unit_source_directory="${program_service_source_directory}/unit/"

    if c_os_support_systemd ; then
        program_service_unit_source_file="${program_service_unit_source_directory}/systemd/${program_name}.service"
        program_service_unit_destination_file="/etc/systemd/system/${program_name}.service"
    else
        program_service_unit_source_file="${program_service_unit_source_directory}/systemV/${program_name}"
        program_service_unit_destination_file="/etc/init.d/${program_name}"
    fi

    program_logrotate_source="${program_template_source_directory}/logrotate/${program_name}"
    program_logrotate_destination="/etc/logrotate.d/${program_name}"

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
        local cpanm_navel_gitchain=$(f_build_cpanm_navel_gitchain navel-{base{,-definition},queue,logger,api} anyevent-fork-rpc-serializer-sereal navel-{base-{daemon,workermanager},mojolicious-plugin-{logger,openapi-stdresponses},anyevent-pool,definition-collector,event} $program_name)

        f_pending "Installing ${cpanm_navel_gitchain}."

        "${CPANM}" $cpanm_navel_gitchain
    }

    f_install_step_4() {
        f_pending "Creating group ${program_group}."

        w_groupadd "${program_group}"
    }

    f_install_step_5() {
        f_pending "Creating user ${program_user} with home directory ${program_home_directory}."

        w_useradd "${program_user}" "${program_group}" "${program_home_directory}"
    }

    f_install_step_6() {
        local from="${program_configuration_source_directory}/."

        f_pending "Copying configuration files from ${from} to ${program_configuration_destination_directory}."

        w_cp -R "${from}" "${program_configuration_destination_directory}"
    }

    f_install_step_7() {
        f_pending "Creating directories ${program_run_directory} and ${program_log_directory}."

        w_mkdir "${program_run_directory}" "${program_log_directory}"
    }

    f_install_step_8() {
        local from="${program_service_default_source_directory}/${program_name}"

        f_pending "Copying default script from ${from} to ${program_service_default_destination_file}."

        w_cp "${from}" "${program_service_default_destination_file}"
    }

    f_install_step_9() {
        f_pending "Templating ${program_service_default_destination_file}."

        "${PERL}" -pi -e "s':PROGRAM_RUN_FILE:'${program_run_file}'g" "${program_service_default_destination_file}" && \
        "${PERL}" -pi -e "s':PROGRAM_RUN_DIR:'${program_run_directory}'g" "${program_service_default_destination_file}" && \
        "${PERL}" -pi -e "s':PROGRAM_LOG_FILE:'${program_log_file}'g" "${program_service_default_destination_file}"
    }

    f_install_step_10() {
        f_pending "Copying unit file from ${program_service_unit_source_file} to ${program_service_unit_destination_file}."

        w_cp "${program_service_unit_source_file}" "${program_service_unit_destination_file}"
    }

    f_install_step_11() {
        f_pending "Templating ${program_service_unit_destination_file}."

        [[ -n "${override_program_binary_directory}" ]] && program_binary_directory="${override_program_binary_directory}"

        program_binary_file="${program_binary_directory}/${program_name}"

        "${PERL}" -pi -e "s':PROGRAM_NAME:'${program_name}'g" "${program_service_unit_destination_file}" && \
        "${PERL}" -pi -e "s':PROGRAM_USER:'${program_user}'g" "${program_service_unit_destination_file}" && \
        "${PERL}" -pi -e "s':PROGRAM_GROUP:'${program_group}'g" "${program_service_unit_destination_file}" && \
        "${PERL}" -pi -e "s':PROGRAM_DEFAULT_DIR:'${program_service_default_destination_directory}'g" "${program_service_unit_destination_file}" && \
        "${PERL}" -pi -e "s':PROGRAM_DEFAULT_FILE:'${program_service_default_destination_file}'g" "${program_service_unit_destination_file}" && \
        "${PERL}" -pi -e "s':PROGRAM_BINARY_BASEDIR:'${program_binary_directory}'g" "${program_service_unit_destination_file}" && \
        "${PERL}" -pi -e "s':PROGRAM_BINARY_FILE:'${program_binary_file}'g" "${program_service_unit_destination_file}" && \
        "${PERL}" -pi -e "s':RUN_DIR:'${run_directory}'g" "${program_service_unit_destination_file}" && \
        "${PERL}" -pi -e "s':PROGRAM_RUN_FILE:'${program_run_file}'g" "${program_service_unit_destination_file}"
    }

    f_install_step_12() {
        f_pending "Configuring service ${program_name} to start at boot."

        w_enable_service_to_start_at_boot "${program_name}"
    }

    f_install_step_13() {
        f_pending "Chmoding (+x) ${program_service_unit_destination_file}."

        w_chmod +x "${program_service_unit_destination_file}"
    }

    f_install_step_14() {
        f_pending "Recursively chowning (${program_user}:${program_group}) ${program_binary_file}, ${program_home_directory}, ${program_service_unit_destination_file}, ${program_run_directory} and ${program_log_directory}."

        w_chown -R "${program_user}:${program_group}" "${program_binary_file}" "${program_home_directory}" "${program_service_unit_destination_file}" "${program_run_directory}" "${program_log_directory}"
    }

    f_install_step_15() {
        f_pending "Installing logrotate."

        w_install_pkg 'logrotate'
    }

    f_install_step_16() {
        f_pending "Copying logrotate file from ${program_logrotate_source} to ${program_logrotate_destination}."

        w_cp "${program_logrotate_source}" "${program_logrotate_destination}"
    }

    f_install_step_17() {
        f_pending "Templating ${program_logrotate_destination}."

        "${PERL}" -pi -e "s':PROGRAM_LOG_FILE:'${program_log_file}'g" "${program_logrotate_destination}"
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

    program_service_default_destination_directory='/etc/sysconfig/'

    program_service_default_destination_file="${program_service_default_destination_directory}/${program_name}"
}

_f_define_for_debian() {
    _f_define

    # set

    APT_GET='apt-get'
    UPDATE_RC_D='update-rc.d'

    mandatory_pkg_to_install_via_pkg_manager+=(
        'libxml2-dev'
    )

    program_service_default_destination_directory='/etc/default/'

    program_service_default_destination_file="${program_service_default_destination_directory}/${program_name}"
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

while getopts 'x:123l' OPT 2>/dev/null ; do
    case "${OPT}" in
        # t)
            # git_tag=${OPTARG} ;;
        x)
            override_program_binary_directory="${OPTARG}" ;;
        1)
            disable_install_step[2]=1 ;;
        2)
            unset disable_install_step[6] ;;
        3)
            unset disable_install_step[15] disable_install_step[16] disable_install_step[17] ;;
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
