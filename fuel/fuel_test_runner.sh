VM_PATH="/devel/VM"
IMAGE_PATH="/devel/fuel"
COG_VM="$VM_PATH/CogVM.app/Contents/MacOS/CogVM"
STACK_VM="$VM_PATH/Squeak 4.2.5beta1U.app/Contents/MacOS/Squeak VM Opt"
SCRIPT="$IMAGE_PATH/fuel_test_runner.st"

PHARO_IMAGES=("Pharo111" "Pharo112" "Pharo12" "Pharo13" "Pharo14" "Pharo20")
SQUEAK_IMAGES_STACK_VM=("Squeak41")
SQUEAK_IMAGES_COG_VM=("Squeak42" "Squeak43" "Squeak44")

#pharo cog
for image in ${PHARO_IMAGES[@]}; do
	echo "running COG_VM $IMAGE_PATH/${image}/${image}.image $SCRIPT"
	exec "$COG_VM" "$IMAGE_PATH/${image}/${image}.image" "$SCRIPT" &
done

#squeak stack
for image in ${SQUEAK_IMAGES_STACK_VM[@]}; do
	echo "running $STACK_VM $IMAGE_PATH/${image}/${image}.image $SCRIPT"
	exec "$STACK_VM" "$IMAGE_PATH/${image}/${image}.image" "$SCRIPT" &
done

#squeak cog
for image in ${SQUEAK_IMAGES_COG_VM[@]}; do
	echo "running $COG_VM $IMAGE_PATH/${image}/${image}.image $SCRIPT"
	exec "$COG_VM" "$IMAGE_PATH/${image}/${image}.image" "$SCRIPT" &
done

exit 0
