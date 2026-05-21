# 동적 할당하기 위해 class_name 등록
class_name DropTable

"""
DataManager가 가공해 준 데이터를 넘겨받아
가중치 누적 차감 알고리즘을 사용하여
실제 게임 내에서 아이템 무작위 추첨을 수행
"""

##################################################
# 외부에서 설정하는 Drop Table 원본 데이터를 저장할 내부 변수
# 클래스 내부에서만 안전하게 사용하기 위해 _를 붙임
var _data: Dictionary = {}

##################################################
# 객체가 메모리에 생성(new)되는 순간 가장 먼저 실행되는 생성자 함수
# 데이터가 없는 빈 껍데기 상태로 아이템을 추천하는 것을 원천 차단
func _init(target_data: Dictionary) -> void:
	_data = target_data

##################################################
# 설정받은 데이터를 바탕으로 아이템을 무작위 추첨하여 item_code를 반환하는 함수
func pick_random_item() -> String:
	# 데이터가 비어있다면 연산이 불가능하므로
	# 에러 로그를 띄우고 빈 문자열을 반환하여 함수를 조기 종료
	if _data.is_empty():
		push_error("Table Data Empty")
		return ""
	
	# 데이터에 존재하는 모든 아이템의 가중치(확률 수치) 총합을 구함
	var total_weight: int = 0
	for item_code in _data:
		total_weight += _data[item_code]["raw_weight"]
	
	# 가중치 총합이 0 이하(데이터 문제 등)라면 뽑기가 불가능하므로 에러 발생
	if total_weight <= 0:
		push_error("Total Weight Error")
		return ""
	
	# 1부터 가중치 총합 사이에서 아이템 추첨을 위한 수치를 뽑음
	var dice: int = randi_range(1, total_weight)
	
	# 가중치 누적 차감 알고리즘 가동
	# 아이템들의 가중치를 차례대로 빼다가, 0 이하가 되는 순간 확정 판정
	for item_code in _data:
		var current_weight: int = _data[item_code]["raw_weight"]
		dice -= current_weight
		# 즉시 아이템 코드를 반환하고 함수 종료
		if dice <= 0:
			return item_code
	
	# 이론상 절대 도달할 수 없는 구역 (Unreachable Code)
	# 정상적인 연산이라면 위 루프 안에서 100% 반환되어야 하지만, 미세한 오차나 버그로 
	# 루프를 탈출했을 때 함수 타입 약속(String)을 지키고 크래시를 막기 위해
	# 에러를 띄우고 빈 값 반환
	push_error("Unreachable Code Reached")
	return ""
