if [ -z "$1" ]; then
	echo "You did not supply the mode argument: 1 to run all tests, 2 to serialize / materialize all objects to / from all images"
	exit 1
elif [ "$1" -ne 1 ] && [ "$1" -ne 2 ]; then
	echo "Mode was $1 but should have been 1 or 2."
	exit 1
fi

MODE="$1"
VM_PATH="/devel/VM"
IMAGE_PATH="/devel/fuel"
COG_VM="$VM_PATH/CogVM.app/Contents/MacOS/CogVM"
STACK_VM="$VM_PATH/Squeak 4.2.5beta1U.app/Contents/MacOS/Squeak VM Opt"
LOADER_SCRIPT="$IMAGE_PATH/fuel_load_packages.st"
TEST_RUNNER_SCRIPT="$IMAGE_PATH/fuel_run_all_tests.st"
SERIALIZATION_SCRIPT="$IMAGE_PATH/fuel_serialize_all_objects.st"
MATERIALIZATION_SCRIPT="$IMAGE_PATH/fuel_materialize_all_objects.st"
FINAL_SCRIPT_BASE="$IMAGE_PATH/run_it"
FINAL_SCRIPT=""

PHARO_IMAGES=("Pharo111" "Pharo112" "Pharo12" "Pharo13" "Pharo14" "Pharo20")
SQUEAK_IMAGES_STACK_VM=("Squeak41")
SQUEAK_IMAGES_COG_VM=("Squeak42" "Squeak43" "Squeak44")

function prepare_final_script(){
	IMAGE_NAME=$1
	FINAL_SCRIPT="${FINAL_SCRIPT_BASE}_${IMAGE_NAME}.st"
	echo $FINAL_SCRIPT
	if [ $MODE = 1 ]; then
		echo "running all tests"
		
		cat "$LOADER_SCRIPT" > "$FINAL_SCRIPT"
		cat "$TEST_RUNNER_SCRIPT" >> "$FINAL_SCRIPT"
	else
		echo "serializing / materializing all objects"
		
		cat "$LOADER_SCRIPT" > "$FINAL_SCRIPT"
		echo -e "\n" >> "$FINAL_SCRIPT"
		
		echo "Smalltalk at: #FuelFormatTestScriptsPath put: '$IMAGE_PATH'." >> "$FINAL_SCRIPT"
		echo -e "\n" >> "$FINAL_SCRIPT"
		
		echo "Smalltalk at: #FuelFormatTestImageNames put: #(" >> "$FINAL_SCRIPT"
		for image in ${PHARO_IMAGES[@]}; do
			echo "'${image}' " >> "$FINAL_SCRIPT"
		done
		for image in ${SQUEAK_IMAGES_STACK_VM[@]}; do
			echo "'${image}' " >> "$FINAL_SCRIPT"
		done
		for image in ${SQUEAK_IMAGES_COG_VM[@]}; do
			echo "'${image}' " >> "$FINAL_SCRIPT"
		done
		echo -e ").\n" >> "$FINAL_SCRIPT"
		
		echo "Smalltalk at: #FuelFormatTestFilename put: '$IMAGE_NAME.fuel'." >> "$FINAL_SCRIPT"
		echo -e "\n" >> "$FINAL_SCRIPT"
		
		cat "$SERIALIZATION_SCRIPT" >> "$FINAL_SCRIPT"
		echo -e "\n" >> "$FINAL_SCRIPT"
		
		cat "$MATERIALIZATION_SCRIPT" >> "$FINAL_SCRIPT"
	fi
}

#pharo cog
# for image in ${PHARO_IMAGES[@]}; do
# 	prepare_final_script ${image}
# 	echo "running COG_VM $IMAGE_PATH/${image}/${image}.image $FINAL_SCRIPT"
# 	exec "$COG_VM" "$IMAGE_PATH/${image}/${image}.image" "$FINAL_SCRIPT" &
# done

#squeak stack
for image in ${SQUEAK_IMAGES_STACK_VM[@]}; do
	prepare_final_script ${image}
	echo "running $STACK_VM $IMAGE_PATH/${image}/${image}.image $FINAL_SCRIPT"
	exec "$STACK_VM" "$IMAGE_PATH/${image}/${image}.image" "$FINAL_SCRIPT" &
done
# 
# #squeak cog
# for image in ${SQUEAK_IMAGES_COG_VM[@]}; do
# 	prepare_final_script ${image}
# 	echo "running $COG_VM $IMAGE_PATH/${image}/${image}.image $FINAL_SCRIPT"
# 	exec "$COG_VM" "$IMAGE_PATH/${image}/${image}.image" "$FINAL_SCRIPT" &
# done
# 
# exit 0
