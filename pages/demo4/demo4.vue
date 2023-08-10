<template>
	<view>
		<form @submit="onSubmit">
			<view class="row">
				<input type="text" name="username"/>
			</view>
			<view class="row">
				<radio-group name="sex">
					<radio value="0">男</radio>
					<radio value="1">女</radio>
					<radio value="2" checked>保密</radio>
				</radio-group>
			</view>
			<view class="row">
				<picker :range="options" name="school" :value="selectSchool" @change="pickerChange">
					<view>点击选择学历：{{options[selectSchool]}}</view>
				</picker>
			</view>
			<view class="row">
				<textarea name="content"></textarea>
			</view>
			
			
			<view class="row">
				<button form-type="submit">提交</button>
				<button form-type="reset">重置</button>
			</view>
		</form>
		{{obj}}
		
		<input type="text" v-model="title"/>
		<view>原标题：{{title}}</view>
		<view>修改后：{{toUpperCase}}</view>
		{{demo}}
		-----sum------------
		<view>
			a:<input type="digit" v-model="a"/>
		</view>
		<view>
			b:<input type="digit" v-model="b"/>
		</view>
		<view>
			a+b={{sum}}
		</view>
	</view>
</template>

<script>
	export default {
		data() {
			return {
				obj:null,
				options:["高中","大学","研究生"],
				selectSchool:2,
				title:"",
				a:0,
				b:0
			};
		},
		methods:{
			onSubmit(e){
				console.log(e);
				this.obj = e.detail.value;
				this.obj.school = this.options[this.selectSchool];
			},
			pickerChange(e){
				this.selectSchool = e.detail.value;
			}
		},
		computed:{
			/* 这里的方法可以当做就是一个data属性
				不同的就是这里的属性可以进行计算
			 */
			demo(){
				if(this.title !=''){
					return this.title+"！！！";
				}
				return '';
			},
			toUpperCase(){
				return this.title.toLocaleUpperCase();
			},
			sum(){
				if(this.a != null && this.b != null){
					return parseInt(this.a) +parseInt(this.b);
				}
				return ''
			}
		}
	}
</script>

<style lang="scss">
input,textarea{
	border:1px solid #ccc;
}
.row{
	margin: 10rpx;
}
</style>
