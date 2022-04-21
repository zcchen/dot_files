wechat_file_dir="$HOME/.DoChat/WeChat Files/"
Application_data_dir="$HOME/.DoChat/Applcation Data"

mkdir -p "${wechat_file_dir}"
mkdir -p "${Application_data_dir}"

docker run \
  --name DoChat \
  --rm \
  -i \
  \
  -v "${wechat_file_dir}":'/home/user/WeChat Files/' \
  -v "${Application_data_dir}":'/home/user/.wine/drive_c/users/user/Application Data/' \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  \
  -e DISPLAY \
  \
  -e XMODIFIERS=@im=fcitx \
  -e GTK_IM_MODULE=fcitx \
  -e QT_IM_MODULE=fcitx \
  -e GID="$(id -g)" \
  -e UID="$(id -u)" \
  \
  --ipc=host \
  --privileged \
  \
  zixia/wechat
