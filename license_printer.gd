extends Node

func _ready() -> void:
	print("This software is using Godot Engine, under the following license:\n")
	print(Engine.get_license_text().indent("\t"))

	print("\n\nThird-party licenses:\n\n")

	print("FreeType\n")
	print("\tPortions of this software are copyright © 1996-2023 The FreeType Project (www.freetype.org). All rights reserved.\n\n")

	print("ENet\n")
	print("\tCopyright (c) 2002-2020 Lee Salzman\n")
	print('\tPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n')
	print("\tThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n")
	print('\tTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.\n\n')

	print("mbed TLS\n")
	print("\tCopyright The Mbed TLS Contributors\n")
	print('\tLicensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at\n')
	print("\thttp://www.apache.org/licenses/LICENSE-2.0\n")
	print('\tUnless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.')

	queue_free()
