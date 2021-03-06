//
//  FormulaStringCalcUtility.m
//  HomeWorkTwo
//
//  Created by HJ on 14/11/4.
//  Copyright (c) 2014年 HJ. All rights reserved.
//

#import "FormulaStringCalcUtility.h"

@implementation FormulaStringCalcUtility

// 字符串加
+ (NSString *)addV1:(NSString *)v1 v2:(NSString *)v2
{
    CGFloat a = [v1 floatValue] + [v2 floatValue];
    return [NSString stringWithFormat:@"%.2f", a];
}

// 字符串减
+ (NSString *)subV1:(NSString *)v1 v2:(NSString *)v2
{
    CGFloat result = [v1 floatValue] - [v2 floatValue];
    return [NSString stringWithFormat:@"%.2f", result];
}

// 字符串乘
+ (NSString *)mulV1:(NSString *)v1 v2:(NSString *)v2
{
    CGFloat result = [v1 floatValue] * [v2 floatValue];
    return [NSString stringWithFormat:@"%.2f", result];
}

// 字符串除
+ (NSString *)divV1:(NSString *)v1 v2:(NSString *)v2
{
    //判断除以0的情况
    if([v2 floatValue] == 0.0)
    {
        return @"0";
    }
    else
    {
        CGFloat result = [v1 floatValue] / [v2 floatValue];
        return [NSString stringWithFormat:@"%.2f", result];
    }
    
}

// 字符串取余 %
+ (NSString *)ramain1:(NSString *)v1 v2:(NSString *)v2
{
    CGFloat result = (int)[v1 integerValue] % (int)[v2 integerValue];
    return [NSString stringWithFormat:@"%.2f", result];
}
    
// 简单只包含 + - 的计算
+ (NSString *)calcSimpleFormula:(NSString *)formula
{
    
    NSString *result = @"0";
    char symbol = '+';
    
    int len = (int)formula.length;
    int numStartPoint = 0;
    for (int i = 0; i < len; i++) {
        char c = [formula characterAtIndex:i];
        if (c == '+' || c == '-') {
            NSString *num = [formula substringWithRange:NSMakeRange(numStartPoint, i - numStartPoint)];
            switch (symbol) {
                case '+':
                    result = [self addV1:result v2:num];
                    break;
                case '-':
                    result = [self subV1:result v2:num];
                    break;
                default:
                    break;
            }
            symbol = c;
            numStartPoint = i + 1;
        }
    }
    if (numStartPoint < len) {
        NSString *num = [formula substringWithRange:NSMakeRange(numStartPoint, len - numStartPoint)];
        switch (symbol) {
            case '+':
                result = [self addV1:result v2:num];
                break;
            case '-':
                result = [self subV1:result v2:num];
                break;
            default:
                break;
        }
    }
    return result;
}

// 获取字符串中的前置数字
+ (NSString *)lastNumberWithString:(NSString *)str
{
    int numStartPoint = 0;
    for (int i = (int)str.length - 1; i >= 0; i--)
    {
        char c = [str characterAtIndex:i];
        if ((c < '0' || c > '9') && c != '.')
        {
            numStartPoint = i + 1;
            break;
        }
    }
    return [str substringFromIndex:numStartPoint];
}

// 获取字符串中的后置数字
+ (NSString *)firstNumberWithString:(NSString *)str
{
    int numEndPoint = (int)str.length;
    for (int i = 0; i < str.length; i++)
    {
        char c = [str characterAtIndex:i];
        //if ((c < '0' || c > '9') && (c != '.') && (c != '-') && (c != '+') )
       if((c < '0' || c > '9') && c != '.')
        {
            numEndPoint = i;
            break;
        }
    }
    return [str substringToIndex:numEndPoint];
}

// 包含 * / 的计算
+ (NSString *)calcNormalFormula:(NSString *)formula
{
    NSRange mulRange = [formula rangeOfString:@"*" options:NSLiteralSearch];
    NSRange divRange = [formula rangeOfString:@"/" options:NSLiteralSearch];
    NSRange remRabge = [formula rangeOfString:@"%" options:NSLiteralSearch];
    // 只包含加减的运算
    if (mulRange.length == 0 && divRange.length == 0 && remRabge.length == 0)
    {
        return [self calcSimpleFormula:formula];
    }
    // 进行乘除运算
    //int index = mulRange.length > 0 ? (int)mulRange.location : (int)divRange.location;
    int index;
    if ((mulRange.location < divRange.location)&&(mulRange.location < remRabge.location))
    {
        index = (int)mulRange.location;
    }
    else if ((divRange.location < mulRange.location) && (divRange.location < remRabge.location))
    {
        index = (int)divRange.location;
    }
    else
    {
        index = (int)remRabge.location;
    }
        
    // 计算左边表达式
    NSString *left = [formula substringWithRange:NSMakeRange(0, index)];
    NSString *num1 = [self lastNumberWithString:left];
    left = [left substringWithRange:NSMakeRange(0, left.length - num1.length)];
    // 计算右边表达式
    NSString *right = [formula substringFromIndex:index + 1];
    NSString *num2 = [self firstNumberWithString:right];
    right = [right substringFromIndex:num2.length];
    // 计算一次乘除结果
    NSString *tempResult = @"0";
    if (index == mulRange.location)  // 乘法
    {
        tempResult = [self mulV1:num1 v2:num2];
        NSString *newFormula = [NSString stringWithFormat:@"%@%@%@", left, tempResult, right];
        return [self calcNormalFormula:newFormula];// 代入计算得到新的公式
    }
    else if(index == divRange.location) //除法
    {
        if ([num2 floatValue] == 0)
        {
            return 0;
        }
        else
        {
            tempResult = [self divV1:num1 v2:num2];
            NSString *newFormula = [NSString stringWithFormat:@"%@%@%@", left, tempResult, right];
            return [self calcNormalFormula:newFormula];// 代入计算得到新的公式
        }
    }
    else  // 余数
    {
        if ([num2 floatValue] < 1)
        {
            return 0;
        }
        else
        {
            tempResult = [self ramain1:num1 v2: num2];
            NSString *newFormula = [NSString stringWithFormat:@"%@%@%@", left, tempResult, right];
            return [self calcNormalFormula:newFormula];// 代入计算得到新的公式
        }
    }
}

// 复杂计算公式计算,接口主方法
+ (NSString *)calcComplexFormulaString:(NSString *)formula
{
    // 左括号
    NSRange lRange = [formula rangeOfString:@"(" options:NSBackwardsSearch];
    // 没有括号进行二步运算(含有乘除加减)
    if (lRange.length == 0)
    {
        return [self calcNormalFormula:formula];
    }
    // 右括号
    NSRange rRange = [formula rangeOfString:@")" options:NSLiteralSearch range:NSMakeRange(lRange.location, formula.length-lRange.location)];
    //判断右括号是否出错
    if(rRange.location < NSNotFound)
    {
        // 获取括号左右边的表达式
        NSString *left = [formula substringWithRange:NSMakeRange(0, lRange.location)];
        NSString *right = [formula substringFromIndex:rRange.location + 1];
        // 括号内的表达式
        NSString *middle = [formula substringWithRange:NSMakeRange(lRange.location+1, rRange.location-lRange.location-1)];
        // 代入计算新的公式
        NSString *newFormula = [NSString stringWithFormat:@"%@%@%@", left, [self calcNormalFormula:middle], right];
        return [self calcComplexFormulaString:newFormula];
    }
    else
    {
        return @"格式错误";
    }
}

@end