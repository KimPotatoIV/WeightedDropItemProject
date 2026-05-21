# 오토로드 등록 스크립트
extends Node

"""
LoadManager가 파싱한 외부 데이터(CSV)를
중앙에서 보관하고 관리하는 매니저로
내부 데이터를 안전하게 보호하기 위해
Getter/Setter 함수를 통해서만 접근하도록 설계
"""

##################################################
# LoadManager에서 가공이 완료된 데이터를 저장할 변수
# 앞에 _를 붙여 '클래스 내부에서만 쓸 변수'임을 명시
var _drop_table_data: Dictionary = {}

##################################################
# 외부에서 안전하게 _drop_table_data을 읽어갈 수 있도록 통로를 열어주는 함수
func get_drop_table_data() -> Dictionary:
	return _drop_table_data

##################################################
# LoadManager가 CSV를 다 읽고 필요에 따라 변환 후,
# 이 함수를 호출하여 데이터를 설정
func set_drop_table_data(data_value: Dictionary) -> void:
	_drop_table_data = data_value
