package com.membercard.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.membercard.entity.Member;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface MemberMapper extends BaseMapper<Member> {}