from rpy2 import robjects
from flask import Flask, jsonify, request, Response, render_template

app=Flask(__name__)

def read_file(file1):
	with open(file1,"r") as f:
		return f.read()

def graph(start_time,hours,day):
	GM=(render_template('Graph_Maker.R', input_time=str(start_time), input_hours=str(hours), input_day=str(day)))
	robjects.r(GM)

@app.route("/",methods=['GET'])
def home():
	if request.method == "GET":
		
		start_time=request.args.get("start_time",0)
		hours=request.args.get("hours",1)
		day=request.args.get("day",1)
		
		graph(start_time,hours,day)
		return read_file("website2.html")

@app.route("/show_graph",methods=['GET'])
def show_graph():
	if request.method == "GET":
		return read_file("Graph.html")

@app.route("/show_graph_denom",methods=['GET'])
def show_graph_denom():
	if request.method == "GET":
		return read_file("Graph_denom.html")


if __name__ == '__main__':
	print("http://192.168.1.10:5001/graph?graph_max_limit=100&graph_min_limit=0&start_time=0&hours=1&day=1&state=1")
	app.run(host='127.0.0.1', port=5005, debug=True)
