#! /bin/zsh

if [[ "$OSTYPE" == "darwin"* ]]; then
   if ! pgrep -f "Xcode" > /dev/null; then
      open ios/Runner.xcworkspace
   fi
fi