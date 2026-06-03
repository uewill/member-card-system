package com.membercard.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.membercard.entity.MemberCard;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface MemberCardMapper extends BaseMapper<MemberCard> {}