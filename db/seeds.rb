#!/usr/bin/env ruby
# coding: utf-8


# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Status.create([
  {:name => "未开始"},
  {:name => "下载队列等待中"},
  {:name => "正在下载"},
  {:name => "下载错误"},
  {:name => "已完成下载"}
])

Format.create([
  {:name => "flv"},
  {:name => "mp4"}
])
