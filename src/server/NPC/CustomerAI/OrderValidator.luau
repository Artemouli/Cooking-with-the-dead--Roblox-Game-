local OrderValidator = {}

function OrderValidator:Validate(plate, task)
	local isValid = true
	local reward = task.Money or 0
	local taskCopy = table.clone(task)
	taskCopy["Money"] = nil

	local ingredients = plate:FindFirstChild("Ingredients")
	if not ingredients then
		return false, reward
	end

	for _, item in ipairs(ingredients:GetChildren()) do
		local name = item.Name
		local cookedCorrectly = item:FindFirstChild("Food Preps") and item["Food Preps"].FullCooked.Value

		if taskCopy[name] == cookedCorrectly then
			taskCopy[name] = nil
		else
			isValid = false
		end
	end

	if next(taskCopy) ~= nil then
		isValid = false
	end

	return isValid, reward
end

return OrderValidator
