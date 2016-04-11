        [Unit]
        Description=Kubernetes Kubelet
        Documentation=https://github.com/kubernetes/kubernetes
        Requires=docker.service
        After=docker.service


        [Service]
        # set env vars properly
        EnvironmentFile=/etc/kubernetes.env
        EnvironmentFile=/etc/instance.env

        #  systemd supports a simple notification protocol that allows daemons to make
        #  systemd aware that they are done initializing
        # Type=notify

        ExecStartPre=/usr/bin/mkdir -p /etc/kubernetes/manifests
        ExecStart=/opt/bin/kubelet $KUBE_KUBELET_NODE_OPTS

        # These settings set both soft and hard limits of various resources for executed
        # processes.
        # Note that most process resource limits configured with these options are
        # per-process, and processes may fork in order to acquire a new set of resources
        # that are accounted independently of the original process, and may thus escape
        # limits set.
        LimitNOFILE=1048576
        LimitNPROC=1048576
        LimitCORE=infinity

        # Specify the maximum number of tasks that may be created in the unit. This
        # ensures that the number of tasks accounted for the unit stays below a specific
        # limit. If assigned the special value "infinity", no tasks limit is applied.
        TasksMax=infinity

        # Takes one of no, on-success, on-failure, on-abnormal, on-watchdog, on-abort,
        # or always. If set to no (the default), the service will not be restarted. If
        # set to on-success, it will be restarted only when the service process exits
        # cleanly. In this context, a clean exit means an exit code of 0, or one of the
        # signals SIGHUP, SIGINT, SIGTERM or SIGPIPE, and additionally, exit statuses
        # and signals specified in SuccessExitStatus=. If set to on-failure, the service
        # will be restarted when the process exits with a non-zero exit code, is
        # terminated by a signal (including on core dump, but excluding the
        # aforementioned four signals), when an operation (such as service reload) times
        # out, and when the configured watchdog timeout is triggered. If set to
        # on-abnormal, the service will be restarted when the process is terminated by a
        # signal (including on core dump, excluding the aforementioned four signals),
        # when an operation times out, or when the watchdog timeout is triggered. If set
        # to on-abort, the service will be restarted only if the service process exits
        # due to an uncaught signal not specified as a clean exit status. If set to
        # on-watchdog, the service will be restarted only if the watchdog timeout for
        # the service expires. If set to always, the service will be restarted
        # regardless of whether it exited cleanly or not, got terminated abnormally by a
        # signal, or hit a timeout.
        Restart=always

        # Configures the time to sleep before restarting a service (as configured with
        # Restart=). Takes a unit-less value in seconds, or a time span value such as
        # "5min 20s". Defaults to 100ms.
        RestartSec=10


        [Install]
        # allows this unit to be enabled via systemctl enable
        WantedBy=multi-user.target

