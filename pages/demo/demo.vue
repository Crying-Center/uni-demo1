<template>
	<view>
		<view>当前标题：{{title}}</view>
		<view>{{num}}</view>
		<view>{{arr}}</view>
		<view>{{arr[0]}}</view>
		<view>{{obj}}</view>
		<view>{{obj.name}}</view>
		-------------------
		<view v-if="state">uniapp学习</view>
		<view v-else-if="day == 4">今天周四</view>
		<view v-else>小程序学习</view><!-- 不需要表达式，前一兄弟元素必须有 v-if 或 v-else-if ,兄弟元素需要紧贴一起 不然报错-->
		
		--------v-if--------
		<view v-if="state">uniapp</view>	<!-- v-if如果条件判定不成立 则dom元素直接被移除 无法获取 -->
		<view v-else>html5cssc</view>
		--------v-show--------
		<view v-show="state">uniapp</view>	<!-- v-show条件判定不成立将使用display:none,dom元素仍然存在 -->
		<view v-show="!state">html5cssc</view>
		
		----------for---------
		<view v-for="(item,index) in arr" class="out">
			<view class="row">{{index+1 + '-' +item}}</view>
		</view>
		<view v-for="(item,index) in goods" :key="index"><!-- 唯一标识符 -->
			<view class="">
				商品名称:{{item.title}}
			</view>
			<view class="">
				商品价格:{{item.price}}
			</view>
		</view>
		
		------------for object-------------
		<view v-for="(value,name,index) in obj">
			{{name}} : {{value}}
		</view>
		
		--------------v-html-------------------
		<view>{{titleHtml}}</view>	<!-- 不会进行HTML解析 -->
		<view v-html="titleHtml"></view> <!-- v-html会进行HTML解析，并且支持小程序 -->
		
		---------------v-bind-----------------
		<image v-bind:src="imgSrc"></image>	<!-- 动态绑定 -->
		<image :src="imgSrc"></image>	<!-- 语法糖 -->
		------------------------------------------------------
		<image :src="'../../static/images/banner'+ item +'.png'" v-for="item in 3"></image>
		
		
		
	</view>
</template>

<script>
	export default {
		data() {
			return {
				imgSrc:"../../static/logo.png",
				title: "zjh学uniApp",
				titleHtml:"<h1>你好</h1>",
				num:133,
				arr:["uni","app",1,2,3],
				obj:{
					name:"章佳煌",
					age:"25"
				},
				state: 1 == 2,
				day:5,
				goods:[
					{
						title:"商品1",
						price:228
					},{
						title:"商品2",
						price:99
					},{
						title:"商品3",
						price:11.9
					}
				]
			};
		}
	}
</script>

<style lang="scss">
.out{
	.row{
		color: red;
		font-size: 50rpx;
	}
}
</style>
