<template>
	<view>
		<!-- 双向绑定（dom元素改变js中的值） 一般用于表单 -->
		<view @click="changeText">标题：{{title}}</view>
		<input type="text" v-model="title"/>
		
		----小案例---
		<view class="out">
			<view class="row">
				<input class="border" type="text" placeholder="input your name..." v-model="message.username"/>	
			</view>
			<view class="row">
				<input class="border" type="text" placeholder="input your phone..." v-model="message.phone"/>
			</view>
			<view>
				<textarea class="border" placeholder="input your notes..." v-model="message.notes"></textarea>
			</view>
			<view>
				<button type="primary" @click="onSubmit">submit</button>
			</view>
		</view>
		{{message}}
	</view>
</template>

<script>
	export default {
		data() {
			return {
				title:"lalala",
				message:{
					username:'',
					phone:'',
					notes:''
				}
			};
		},
		methods:{
			changeText(){
				this.title = Math.random()
			},
			onSubmit(){
				console.log(this.message)
			}
		}
	}
</script>

<style lang="scss">
input{
	// border:1px solid #ccc;
}

.out{
	padding: 30rpx;
	.row{
		margin-bottom: 10rpx;
	}
	.border{
		border: 1px solid #ccc;
		width: 100%;
		padding: 10rpx;
	}
}

</style>
