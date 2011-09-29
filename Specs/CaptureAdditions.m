#import "CaptureAdditions.h"
#import "KWMessagePattern.h"

@implementation KWCaptureSpy
@dynamic argument;

- (id)initWithArgumentIndex:(NSUInteger)index {
  if ((self = [super init])) {
    _argumentIndex = index;
  }
  return self;
}

- (id)argument {
  if (!_argument) {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Argument requested  has yet to be captured." userInfo:nil];    
  }
  
  if ([_argument isKindOfClass:NSClassFromString(@"__NSStackBlock__")]) {
    return [[_argument copy] autorelease];
  } else {
    return [[_argument retain] autorelease];
  }      
}

- (void)object:(id)anObject didReceiveInvocation:(NSInvocation *)anInvocation {
  if (!_argument) {
    id argument = nil;
    [anInvocation getArgument:&argument atIndex:2 + _argumentIndex];
    if ([argument isKindOfClass:NSClassFromString(@"__NSStackBlock__")]) {
      _argument = [argument copy];
    } else {
      _argument = [argument retain];
    }    
  }
}

@end

@implementation KWMock (CaptureAdditions)
- (KWCaptureSpy *)capture:(SEL)selector atIndex:(NSUInteger)index andReturn:(id)value {
  KWCaptureSpy *spy = [[[KWCaptureSpy alloc] initWithArgumentIndex:index] autorelease];
  KWMessagePattern *pattern = [KWMessagePattern messagePatternWithSelector:selector];
  [self stubMessagePattern:pattern andReturn:value];
  [self addMessageSpy:spy forMessagePattern:pattern];
  return  spy;  
}

- (KWCaptureSpy *)capture:(SEL)selector atIndex:(NSUInteger)index {
  KWCaptureSpy *spy = [[[KWCaptureSpy alloc] initWithArgumentIndex:index] autorelease];
  [self addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:selector]];
  return  spy;
}

- (KWCaptureSpy *)capture:(SEL)selector atIndex:(NSUInteger)index argumentFilters:(NSArray *)array {
  KWCaptureSpy *spy = [[[KWCaptureSpy alloc] initWithArgumentIndex:index] autorelease];
  [self addMessageSpy:spy forMessagePattern:[KWMessagePattern messagePatternWithSelector:selector argumentFilters:array]];
  return  spy;  
}

@end
