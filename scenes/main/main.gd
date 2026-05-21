extends Node2D

"""
사용자의 키 입력을 받아 Drop Table 시스템을 실제로 가동하고
Output창에 결과를 출력하는 테스트 스크립트
"""

##################################################
# 매 프레임마다 플레이어의 키 입력을 감시
func _process(delta: float) -> void:
	# ui_accept 키(스페이스 혹은 엔터)를 누른 순간 딱 한 번만 발동
	if Input.is_action_just_pressed("ui_accept"):
		_drop_item()

##################################################
# 임의의 확률로 아이템 드롭 결과를 연산하고 출력하는 함수
func _drop_item() -> void:
	# DataManager에 있는 데이터를 복사
	var drop_data: Dictionary = DataManager.get_drop_table_data()
	
	# 일회용 인스턴스를 메모리 공간에 새로 올림
	var loot_roller: DropTable = DropTable.new(drop_data)
	
	# 임의의 확률로 총 10번 반복하여 제대로 동작하는지 확인
	for i in range(10):
		# DropTable에 임의의 확률로 아이템을 무작위 추첨하도록 요청
		var rolled_code: String = loot_roller.pick_random_item()
		
		# 성공적으로 결과가 반환되었다면, 정보를 정렬해 출력
		if rolled_code != "":
			var item_name: String = drop_data[rolled_code]["item_name"]
			print("[%02d회] 코드: %s | 이름: %s" % [i + 1, rolled_code, item_name])
		else:
			# 정상적인 데이터가 아닐 때만 시스템 에러를 발생시킴
			push_error("Loot System Error")
