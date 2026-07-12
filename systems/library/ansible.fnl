(local common (require :systems.library.common))

(local host-file :systems/hosts.ini)
(local config-file (if (= :Darwin (common.os-name))
                       :systems/macos/ansible.cfg
                       :systems/linux/ansible.cfg))

(fn run [command]
  (let [str-cmd (table.concat command " ")
        envar (.. :ANSIBLE_CONFIG= config-file " ")]
    (os.execute (.. envar str-cmd))))

(fn ping []
  (run [:ansible :-c :local :-m :ping :-i host-file :Workstation]))

(fn setup []
  (print :pong!!))

{: setup : ping}
