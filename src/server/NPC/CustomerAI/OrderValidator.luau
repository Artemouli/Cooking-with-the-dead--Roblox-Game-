local OrderValidator = {}

function OrderValidator:Validate(plate, task)
	local isValid = true
	local reward = task.Money or 0
	local taskCopy = table.clone(task)
	taskCopy["Money"] = nil

	local ingredients = plate:FindFirstChild("Ingredients")
	if not ingredients then
		print("no ingredients")
		return false, reward
	end

	print(taskCopy)

	for _, item in ipairs(ingredients:GetChildren()) do
		local name = item.Name
		print(name)
		local cookedCorrectly = item:FindFirstChild("Food Preps") and item["Food Preps"].FullCooked.Value
		print(cookedCorrectly)

		-- accessing the task ingredient
		local taskIngredient = taskCopy[name]
		if taskIngredient then
			-- check if ingredient is cooked correctly
			if taskIngredient["Cooked"] == cookedCorrectly then
				-- check if the quantity of required ingredients is over 1
				if taskIngredient["Quantity"] > 1 then
					taskIngredient["Quantity"] -= 1
				else
					taskCopy[name] = nil
				end
			else
				isValid = false
			end
		else
			-- ingredient that the player has added is not actually in the recipe
			isValid = false
			break
		end
	end

	if next(taskCopy) ~= nil then
		isValid = false
	end

	return isValid, reward
end

return OrderValidator
