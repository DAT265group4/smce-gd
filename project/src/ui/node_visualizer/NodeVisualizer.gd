#
#  NodeVisualizer.gd
#  Copyright 2021 ItJustWorksTM
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

class_name NodeVisualizer
extends Label

var _node: Node = null
var _visual_func: String = ""

func display_node(node: Node, visual_func: String) -> bool:
	if ! node || ! node.has_method(visual_func):
		return false
	_node = node
	_visual_func = visual_func
	
	return true

func _process(_delta: float) -> void:
	if ! _node:
		return
	
	text = _node.call(_visual_func)
