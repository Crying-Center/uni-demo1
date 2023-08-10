<template>
	<view>
		<view v-on:click="onClick">{{title}}</view>
		<button @click="numIncrease">num:{{num}}</button>	<!-- 简写v-on: -->
		
		<view class="box" :style="{background:bgcolor}" @click="changeBgColor">
			{{ramdom}}
		</view>
		
		<view class="block" :class="{myactive:state}" @click="changeStete"></view>
		
		<view class="block" :class="state ? 'myactive' : '' "></view>
		
		<view class="nav">
			<view class="item" :class="navIndex == index ? 'active' : ''" v-for="(item,index) in navArr" :key="item.id" @click="clickNav(index)">
				{{item.title}}
			</view>
		</view>
	</view>
</template>

<script>
	export default {
		data() {
			return {
				title:"你好",
				num:0,
				bgcolor:"red",
				ramdom:Math.trunc(Math.random() * 1000),
				state:false,
				navArr:[
					{id:"1",title:"首页"},
					{id:"2",title:"介绍"},
					{id:"3",title:"教程"},
					{id:"4",title:"组件"}
				],
				navIndex:5
			};
		},
		methods:{
			onClick:function(){
				this.title="hello"
			},
			numIncrease(){	/* 简写 */
				this.num++	
			},
			changeBgColor(){
				let color = '#' + String(Math.random()).substring(3,6);
				let randomNext = Math.trunc(Math.random() * 1000)
				this.bgcolor=color;
				this.ramdom=randomNext;
			},
			changeStete(){
				this.state = !this.state
			},
			clickNav(e){
				this.navIndex = e
			}
		}
	}
</script>

<style lang="scss">
.box{
	width: 200rpx;
	height: 200rpx;
	background-color: pink;
}

.block{
	width: 300rpx;
	height: 300rpx;
	background-color: hotpink;
}

.myactive{
	width: 400rpx;
	height: 400rpx;
	border-radius: 20rpx;
	background-color: green;
}

.nav{
	display: flex; /* 一行内显示*/
	justify-content: space-around;
	align-items: center;
	.item{
		flex: 1; /* 均匀分布*/
		line-height: 90rpx;
		background-color: #ccc;
		text-align: center;
		&.active{
			background-color: green;
			color: #fff;
		}
	}
}
</style>
